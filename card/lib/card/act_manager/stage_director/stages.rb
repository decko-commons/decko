class Card
  class ActManager
    STAGES = %i[initialize prepare_to_validate validate prepare_to_store
                store finalize integrate after_integrate integrate_with_delay].freeze
    stage_index = {}
    STAGES.each_with_index do |stage, i|
      stage_index[stage] = i
    end
    STAGE_INDEX = stage_index.freeze

    class StageDirector
      module Stages
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
          stage && (in?(opts[:during]) || before?(opts[:before]) || after?(opts[:after])) || true
        end

        def before? allowed_phase
          allowed_phase && STAGE_INDEX[allowed_phase] > STAGE_INDEX[stage]
        end

        def after? allowed_phase
          allowed_phase && STAGE_INDEX[allowed_phase] < STAGE_INDEX[stage]
        end

        def in? allowed_phase
          allowed_stage && (allowed_phase == stage ||
                            (allowed_phase.is_a?(Array) && allowed_phase.include?(stage)))
        end

        def finished_stage? stage
          @stage > stage_index(stage)
        end

        def reset_stage
          @stage = -1
        end
      end
    end
  end
end
