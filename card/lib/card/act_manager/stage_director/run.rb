class Card
  class ActManager
    class StageDirector
      # methods for running stages
      module Run
        def catch_up_to_stage next_stage
          return if @delay && next_stage != :integrate_with_delay

          upto_stage(next_stage) do |stage|
            run_stage stage
          end
        end

        def run_delayed_event act
          @running = true
          @act = act
          @stage = stage_index(:integrate_with_delay)
          yield
          run_subcard_stages :integrate_with_delay
        end

        def delay!
          @delay = true
        end

        def restart
          @running = false
          @stage = nil
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

          invalid_next_stage! new_stage if @stage < new_stage - 1
          @card.errors.empty? || new_stage > stage_index(:validate)
        end

        def invalid_next_stage! stage
          raise Card::Error, "stage #{stage_symbol(stage - 1)} was " \
                             "skipped for card #{@card}"
        end

        def run_stage stage, &block
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
          prepare_for_phases if stage == :initialize
        end

        def execute_stage_run stage, &block
          # in the store stage it can be necessary that
          # other subcards must be saved before we save this card
          return store(&block) if stage == :store

          run_stage_callbacks stage
          run_subcard_stages stage
          run_final_stage_callbacks stage
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

        def run_subcard_stages stage
          each_subcard_director do |subdir|
            condition = block_given? ? yield(subdir) : true
            subdir.catch_up_to_stage stage if condition
          end
        end

        def each_subcard_director
          subdirectors.each do |subdir|
            yield subdir unless subdir.head?
          end
        ensure
          @card.handle_subcard_errors
        end

        def run_final_stage_callbacks stage
          run_stage_callbacks stage, "_final"
        end
      end
    end
  end
end
