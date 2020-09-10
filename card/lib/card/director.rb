class Card
  # Directs the symphony of a card {act Card::Act}.
  #
  # Each act is divided into {actions Card::Action}: one for each card. There are three
  # action types: create, update, and delete.
  #
  # Each action is divided into three phases: validation, storage, and integration.
  #
  # Each phase is divided into three stages, as follows
  #
  # validation:
  #   * (V-I) initialize
  #   * (V-P) prepare_to_validate
  #   * (V-V) validate
  #
  # storage:
  #   * (S-P) prepare_to_store
  #   * (S-S) store
  #   * (S-F) finalize
  #
  # integration:
  #   * (I-I) integrate
  #   * (I-A) after_integrate
  #   * (I-D) integrate_with_delay stage (IGwD)
  #
  # The table below gives you an overview what you can do in which stage:
  #
  #                                  validation    |    storage    |  integration
  #                                 V-I  V-P  V-V  | S-P  S-S  S-F | I-I  I-A  I-D
  #--------------------------------------------------------------------------------
  # ACTIONS:
  #    attach subcard               yes! yes! yes  | yes  yes  yes | yes  yes  no
  #    detach subcard               yes! yes! yes  | yes  no   no! |      no!
  #    validate                     yes  yes  yes! |      no       |      no
  # 1) insecure change              yes  yes! no   |      no!      |      no!
  # 2) secure change                     yes       | yes! no!  no! |      no!
  #    abort                             yes!      |      yes      |      yes
  #    add errors                        yes!      |      no!      |      no!
  #    create/update other cards         yes       |      yes      |      yes!
  #    has id (new card)                 no        | no   no?  yes |      yes
  #    within web request                yes       |      yes      | yes  yes  no
  # 3) within transaction                yes       |      yes      |      no

  # VALUES:
  #    dirty attributes                  yes       |      yes      |      yes
  #    params                            yes       |      yes      |      yes
  #    success                           yes       |      yes      |      yes
  #    session                           yes       |      yes      | yes  yes  no
  #
  #
  # Explanation:
  #  yes!  the recommended stage to do that
  #  yes   ok to do it here
  #  no    not recommended; risky but not guaranteed to fail
  #  no!   never do it here. it won't work or will break things
  #
  # if there is only a single entry in a phase column it counts for all stages
  # of that phase
  #
  # 1) 'insecure' means a change that might make the card invalid to save
  # 2) 'secure' means you're sure that the change won't invalidate the card
  # 3) If an exception is raised in the validation or storage phase
  #    everything will rollback. If an integration event fails, db changes
  #    of the other two phases will remain persistent, and other integration
  #    events will continue to run.
  #
  #   .--.      .--.      .--.      .--.      .--.      .--.      .--.      .--.
  # :::::.\::::::::.\::::::::.\::::::::.\::::::::.\::::::::.\::::::::.\::::::::.\
  # '      `--'      `--'      `--'      `--'      `--'      `--'      `--'      `
  #
  # Only one act can be performed at a time in any given Card process. Information about
  # that act is managed by Director class methods. Every act is associated with a
  # single "main" card.
  #
  # The act, however, may involve many cards/actions. Each action has its own
  # Director instance that leads the card through all its stages. When a card action (A1)
  # initiates a new action on a different card (A2), a new Director object is initialized.
  # The new A2 subdirector's @parent is the director of the A1 card. Conversely, the
  # A1 card stores a SubdirectorArray in @subdirectors to give it access to A2's
  # Director and any little Director babies to which it gave birth.
  #
  # Subdirectors follow one of two distinct patterns:
  #
  # 1. {Subcards Card::Subcards}. When a card is altered using the subcards API, the
  #    director follows a "breadth-first" pattern. For each stage a card runs its
  #    stage events and then triggers its subcards to run that stage before proceeding
  #    to the next stage. If a subcard is added in a stage then by the end of that
  #    stage the director will catch it up to the current stage.
  # 2. Subsaves. When a card is altered by a direct save (Card.create(!), card.update(!),
  #    card.delete(!), card.save(!)...), then the validation and storage phases are
  #    executed immediately (depth-first), returning the saved card. The integration
  #    phase, however, is executed following the same pattern as with subcards.
  #
  # Let's consider a subcard example. Suppose you define the following event on
  # self/bar.rb
  #
  # event :met_a_foo_at_the_bar, :prepare_to_store, on: :update do
  #   add_subcard "foo"
  # end
  #
  # And then you run Card[:bar].update!({})
  #
  # When bar reaches the event in its prepare_to_store stage, the foo subcard will be
  # added. After that stage ends, the stages :initialize, :prepare_to_validate,
  # :validate and :prepare_to_store are executed for foo so that it is now caught
  # up with Bar at the prepare_to_store stage.
  #
  # If you have subcards within subcards, stages are executed preorder depth-first.
  #
  # Eg, assuming:
  # - A has subcards AA and AB
  # - AA has subcard AAA
  # - AB has subcard ABA
  # ...then the order of execution is A -> AA -> AAA -> AB -> ABA.
  #
  # A special case can happen in the store stage when a supercard needs a subcard's id
  # (for example as left_id or as type_id) and the subcard doesn't have an id yet
  # (because it gets created in the same act). In this case the subcard's store stage
  # is executed BEFORE the supercard's store stage.
  class Director
    extend EventDelay
    extend ActDirection

    include Stages
    include Phases
    include Run
    include Store

    attr_accessor :act, :card, :stage, :parent, :subdirectors
    attr_reader :running
    alias_method :running?, :running

    def initialize card, parent
      @card = card
      @card.director = self
      # for read actions there is no validation phase
      # so we have to set the action here
      @stage = nil
      @running = false
      @prepared = false
      @parent = parent
      @subdirectors = SubdirectorArray.initialize_with_subcards(self)
      register
    end

    def main?
      parent.nil?
    end

    def head?
      @head || main?
    end

    def register
      Director.add self
    end

    def unregister
      Director.delete self
    end

    def delete
      @parent&.subdirectors&.delete self
      @card.director = nil
      @subdirectors.clear
      @stage = nil
      @action = nil
    end

    def appoint card
      reset_stage
      update_card card
      @head = true
    end

    def abort
      @abort = true
    end

    def need_act
      act_director = main_director
      raise Card::Error, "act requested without a main director" unless act_director

      @act = act_director.act ||= Director.need_act
    end

    def main_director
      return self if main?

      Director.act_director || (@parent&.main_director)
    end

    def to_s level=1
      str = @card.name.to_s.clone
      if @subdirectors.present?
        subs = subdirectors.map { |d| "  " * level + d.to_s(level + 1) }.join "\n"
        str << "\n#{subs}"
      end
      str
    end

    def replace_card card
      card.action = @card.action
      card.director = self
      @card = card
      reset_stage
      catch_up_to_stage @stage if @stage
    end

    def update_card card
      old_card = @card
      @card = card
      Director.card_changed old_card
    end
  end
end
