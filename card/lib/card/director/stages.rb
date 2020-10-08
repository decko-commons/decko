class Card
  class Director
    # Methods for intepreting stages of an action
    module Stages
      STAGES = %i[initialize prepare_to_validate validate
                  prepare_to_store store finalize integrate
                  after_integrate integrate_with_delay].freeze
      STAGE_INDEX = STAGES.each_with_index.with_object({}) do |(stage, index), hash|
        Card.define_callbacks "#{stage}_stage", "#{stage}_final_stage"
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

      def previous_stage_index from_stage=nil
        from_stage ||= @stage
        stage_index(from_stage) - 1
      end

      def previous_stage_symbol from_stage=nil
        stage_symbol previous_stage_index(from_stage)
      end

      def before? *args
        stage_test(*args) { |r, t| r > t }
      end

      def in_or_before? *args
        stage_test(*args) { |r, t| r >= t }
      end

      def after? *args
        stage_test(*args) { |r, t| r < t }
      end

      def in_or_after? *args
        stage_test(*args) { |r, t| r <= t }
      end

      def during? *args
        stage_test(*args) { |r, t| r == t }
      end

      def stage_test reference_stage, test_stage=nil
        test_stage ||= @stage
        yield stage_index(reference_stage), stage_index(test_stage)
      end
    end
  end
end
