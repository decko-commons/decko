class Card
  def restore_changes_information
    # restores changes for integration phase
    # (rails cleared them in an after_create/after_update hook which is
    #  executed before the integration phase)
    return unless saved_changes.present?

    @mutations_from_database = mutations_before_last_save
  end

  def clean_after_stage_fail
    @action = nil
    # expire_pieces
    # subcards.each(&:expire_pieces)
  end

  class ActManager
    # A 'StageDirector' executes the stages of a card when the card gets
    # created, updated or deleted.
    # For subcards, i.e. other cards that are changed in the same act, a
    # StageDirector has StageSubdirectors that take care of the stages for
    # those cards
    #
    # In general a stage is executed for all involved cards before the
    # StageDirector proceeds with the next stage.
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
    class StageDirector
      include Stages
      include Phases
      include Run
      include Store

      attr_accessor :prior_store, :act, :card, :stage, :parent,
                    :subdirectors, :transact_in_stage
      attr_reader :running
      alias_method :running?, :running

      def initialize card, opts={}
        @card = card
        @card.director = self
        # for read actions there is no validation phase
        # so we have to set the action here
        @card.identify_action

        @stage = nil
        @running = false
        @prepared = false
        @parent = opts[:parent]
        # has card to be stored before the supercard?
        @prior_store = opts[:priority]
        @call_after_store = []
        @subdirectors = SubdirectorArray.initialize_with_subcards(self)
        register
      end

      def main?
        parent.nil?
      end

      def register
        ActManager.add self
      end

      def unregister
        ActManager.delete self
      end

      def delete
        @parent&.subdirectors&.delete self
        @card.director = nil
        @subdirectors.clear
        @stage = nil
        @action = nil
      end

      def replace_card card
        card.action = @card.action
        card.director = self
        @card = card
        reset_stage
        catch_up_to_stage @stage if @stage
      end

      def abort
        @abort = true
      end

      def call_after_store &block
        @call_after_store << block
      end

      def need_act
        act_director = main_director
        unless act_director
          raise Card::Error, "act requested without a main stage director"
        end

        @act = act_director.act ||= ActManager.need_act
      end

      def main_director
        return self if main?

        ActManager.act_director || (@parent&.main_director)
      end

      def to_s level=1
        str = @card.name.to_s.clone
        if @subdirectors.present?
          subs = subdirectors.map { |d| "  " * level + d.to_s(level + 1) }.join "\n"
          str << "\n#{subs}"
        end
        str
      end

      def update_card card
        old_card = @card
        @card = card
        ActManager.card_changed old_card
      end
    end
  end
end
