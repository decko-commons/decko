class Card
  # Directs the symphony of a {card act Card::Act}.
  #
  # Each act is divided into actions: one for each card.
  # Each action is divided into three phases: validation, storage, and integration.
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
  #
  # Every card that is part of an act the Director creates a
  # {Director} that leads the card through all its stages.
  # Because cards sometimes get expired and reloaded during an act we need
  # this global object to ensure that the stage information doesn't get lost
  # until the act is finished.
  #
  # The process of creating an act/writing a card change to the database
  # is divided into 8 stages that are grouped in 3 phases.
  #
  #
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
  # 3) create other cards                yes       |      yes      |      yes
  #    has id (new card)                 no        | no   no?  yes |      yes
  #    within web request                yes       |      yes      | yes  yes  no
  # 4) within transaction                yes       |      yes      |      no

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
  #  no    not recommended; chance to mess things up
  #        but if something forces you to do it here you can try
  #  no!   never do it here. it won't work or will break things
  #
  # if there is only a single entry in a phase column it counts for all stages
  # of that phase
  #
  # 1) 'insecure' means a change of a card attribute that can possibly make
  #    the card invalid to save
  # 2) 'secure' means you are sure that the change doesn't affect the validation
  # 3) In all stages except IGwD:
  #    If you call 'create', 'update' or 'save' the card will become
  #    part of the same act and all stage of the validation and storage phase
  #    will be executed immediately for that card. The integration phase will be
  #    executed together with the act card and its subcards.
  #
  #    In IGwD all these methods create a new act.
  # 4) This means if an exception is raised in the validation or storage phase
  #    everything will rollback. If the integration phase fails the db changes
  #    of the other two phases will remain persistent.
  #
  #

  # A 'Director' executes the stages of a card when the card gets
  # created, updated or deleted.
  # For subcards, i.e. other cards that are changed in the same act, a
  # Director has StageSubdirectors that take care of the stages for
  # those cards
  #
  # In general a stage is executed for all involved cards before the
  # Director proceeds with the next stage.
  # Only exception is the finalize stage.
  # The finalize stage of a subcard is executed immediately after its store
  # stage. When all subcards are finalized the supercard's finalize stage is
  # executed.
  #
  # If a subcard is added in a stage then it catches up at the end of the
  # stage to the current stage.
  # For example if you add a subcard in a card's :prepare_to_store stage then
  # after that stage the stages :initialize, :prepare_to_validate,
  # :validate and :prepare_to_store are executed for the subcard.
  #
  # Stages are executed with pre-order depth-first search.
  # That means if A has subcards AA and AB; AAA is subcard of AA and ABA
  # subcard of AB then the order of execution is
  # A -> AA -> AAA -> AB -> ABA
  #
  # A special case can happen in the store phase.
  # If the id of a subcard is needed for a supercard
  # (for example as left_id or as type_id) and the subcard doesn't
  # have an id yet (because it gets created in the same act)
  # then the subcard's store stage is executed before the supercard's store
  # stage

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
      unless act_director
        raise Card::Error, "act requested without a main stage director"
      end

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
