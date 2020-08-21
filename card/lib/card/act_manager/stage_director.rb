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
      include Stage
      include Phases

      attr_accessor :prior_store, :act, :card, :stage, :parent, :main,
                    :subdirectors, :transact_in_stage
      attr_reader :running
      alias_method :running?, :running
      alias_method :main?, :main

      def initialize card, opts={}, main=true
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
        @main = main
        @subdirectors = SubdirectorArray.initialize_with_subcards(self)
        register
      end

      def register
        ActManager.add self
      end

      def unregister
        ActManager.delete self
      end

      def delete
        @card.director = nil
        @subdirectors.clear
        @stage = nil
        @action = nil
      end

      def prepare_for_phases
        @card.prepare_for_phases unless @prepared
        @prepared = true
        @subdirectors.each(&:prepare_for_phases)
      end

      def catch_up_to_stage next_stage
        if @transact_in_stage
          return if @transact_in_stage != next_stage

          next_stage = :integrate_with_delay
        end
        upto_stage(next_stage) do |stage|
          run_single_stage stage
        end
      end

      def run_delayed_event act
        @running = true
        @act = act
        @stage = stage_index(:integrate_with_delay)
        yield
        run_subdirector_stages :integrate_with_delay
      end

      def rerun_up_to_current_stage
        old_stage = @stage
        reset_stage
        catch_up_to_stage old_stage if old_stage
      end

      def replace_card card
        card.action = @card.action
        card.director = self
        @card = card
        rerun_up_to_current_stage
      end

      def reset_stage
        @stage = -1
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
        if main?
          self
        else
          ActManager.act_director || (@parent&.main_director)
        end
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

      def finished_stage? stage
        @stage > stage_index(stage)
      end

      private

      def upto_stage stage
        @stage ||= -1
        (@stage + 1).upto(stage_index(stage)) do |i|
          yield stage_symbol(i)
        end
      end

      def valid_next_stage? stage
        new_stage = stage_index(stage)
        @stage ||= -1
        return if @stage >= new_stage

        if @stage < new_stage - 1
          raise Card::Error, "stage #{stage_symbol(new_stage - 1)} was " \
                             "skipped for card #{@card}"
        end
        @card.errors.empty? || new_stage > stage_index(:validate)
      end

      def run_single_stage stage, &block
        return true unless valid_next_stage? stage

        # puts "#{@card.name}: #{stage} stage".red
        prepare_stage_run stage
        execute_stage_run stage, &block
      rescue StandardError => e
        @card.clean_after_stage_fail
        raise e
      end

      def prepare_stage_run stage
        @stage = stage_index stage
        return unless stage == :initialize

        @running ||= true
        prepare_for_phases
      end

      def execute_stage_run stage, &block
        # in the store stage it can be necessary that
        # other subcards must be saved before we save this card
        if stage == :store
          store(&block)
        else
          run_stage_callbacks stage
          run_subdirector_stages stage
          run_final_stage_callbacks stage
        end
      end

      def run_stage_callbacks stage, callback_postfix=""
        Rails.logger.debug "#{stage}: #{@card.name}"
        # we use abort :success in the :store stage for :save_draft
        if stage_index(stage) <= stage_index(:store) && !main?
          @card.abortable do
            @card.run_callbacks :"#{stage}#{callback_postfix}_stage"
          end
        else
          @card.run_callbacks :"#{stage}#{callback_postfix}_stage"
        end
      end

      def run_final_stage_callbacks stage
        run_stage_callbacks stage, "_final"
      end

      def run_subdirector_stages stage
        @subdirectors.each do |subdir|
          subdir.catch_up_to_stage stage
        end
      ensure
        @card.handle_subcard_errors
      end

      # handle the store stage
      # The tricky part here is to preserve the dirty marks on the subcards'
      # attributes for the finalize stage.
      # To achieve this we can't just call the :store and :finalize callbacks on
      # the subcards as we do in the other phases.
      # Instead we have to call `save` on the subcards
      # and use the ActiveRecord :around_save callback to run the :store and
      # :finalize stages
      def store &save_block
        raise Card::Error, "need block to store main card" if main? && !block_given?

        # the block is the ActiveRecord block from the around save callback that
        # saves the card
        if block_given?
          run_stage_callbacks :store
          store_with_subcards(&save_block)
        else
          trigger_storage_phase_callback
        end
      end

      def store_with_subcards
        store_pre_subcards
        yield
        @call_after_store.each { |handle_id| handle_id.call(@card.id) }
        store_post_subcards
        true.tap { @virtual = false } # TODO: find a better place for this
      ensure
        @card.handle_subcard_errors
      end

      # store subcards whose ids we need for this card
      def store_pre_subcards
        @subdirectors.each do |subdir|
          next unless subdir.prior_store

          subdir.catch_up_to_stage :store
        end
      end

      def store_post_subcards
        @subdirectors.each do |subdir|
          next if subdir.prior_store

          subdir.catch_up_to_stage :store
        end
      end

      # trigger the storage_phase, skip the other phases
      # At this point the :prepare_to_store stage was already executed
      # by the parent director. So the storage phase will only run
      # the :store stage and the :finalize stage
      def trigger_storage_phase_callback
        @stage = stage_index :prepare_to_store
        @card.save_as_subcard!
      end
    end

    class StageSubdirector < StageDirector
      def initialize card, opts={}
        super card, opts, false
      end

      def delete
        @parent&.subdirectors&.delete self
        super
      end
    end
  end
end
