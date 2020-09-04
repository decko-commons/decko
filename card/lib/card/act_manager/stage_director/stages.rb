class Card
  class ActManager
    class StageDirector
      # Methods for intepreting stages of an action
      module Stages
        STAGES = %i[initialize prepare_to_validate validate prepare_to_store
                    store finalize integrate after_integrate integrate_with_delay].freeze
        STAGE_INDEX = STAGES.each_with_index.with_object({}) do |(stage, index), hash|
          hash[stage] = index
        end.freeze

        def stage_symbol index
          case index
          when Symbol
            return index if STAGE_INDEX[index]
          when Integer
            return STAGES[index] if index < STAGES.size
          end
          raise Card::Error, "not a valid stage index: #{index}"
        end

        def stage_index stage
          case stage
          when Symbol then
            STAGE_INDEX[stage]
          when Integer then
            stage
          else
            raise Card::Error, "not a valid stage: #{stage}"
          end
        end

        def stage_ok? opts
          return false unless stage
          test = %i[during before after].find { |t| opts[t] }
          test ? send("#{test}?", opts[t]) : true
        end

        def finished_stage? stage
          @stage > stage_index(stage)
        end

        def reset_stage
          @stage = -1
        end

        private

        def before? allowed_phase
          STAGE_INDEX[allowed_phase] > STAGE_INDEX[stage]
        end

        def after? allowed_phase
          STAGE_INDEX[allowed_phase] < STAGE_INDEX[stage]
        end

        def during? allowed_phase
          return true if allowed_phase == stage

          allowed_phase.is_a?(Array) && allowed_phase.include?(stage)
        end
      end
    end
  end
end
