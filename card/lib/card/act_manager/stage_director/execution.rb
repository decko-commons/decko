class Card
  class ActManager
    class StageDirector
      module Execution
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

          callbacks = :"#{stage}#{callback_postfix}_stage"
          if stage_index(stage) <= stage_index(:store) && !main?
            @card.abortable { @card.run_callbacks callbacks }
          else
            @card.run_callbacks callbacks
          end
        end

        def run_final_stage_callbacks stage
          run_stage_callbacks stage, "_final"
        end

        def run_subdirector_stages stage
          @subdirectors.each do |subdir|
            cond = block_given? ? yield(subdir) : true
            subdir.catch_up_to_stage stage if cond
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
          run_subdirector_stages :store, &:prior_store
        end

        def store_post_subcards
          run_subdirector_stages(:store) { |subdir| !subdir.prior_store }
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
    end
  end
end
