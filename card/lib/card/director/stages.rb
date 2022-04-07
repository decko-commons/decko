class Card
  class Director
    # Methods for interpreting stages of an action
    module Stages
      SYMBOLS = %i[initialize prepare_to_validate validate
                 prepare_to_store store finalize integrate
                 after_integrate integrate_with_delay].freeze

      INDECES = SYMBOLS.each_with_index.with_object({}) do |(stage, index), hash|
        Card.define_callbacks "#{stage}_stage", "#{stage}_final_stage"
        hash[stage] = index
      end.freeze

      def stage_symbol index
        if index.is_a?(Symbol) && INDECES[index]
          index
        elsif index.is_a?(Integer) && index < SYMBOLS.size
          SYMBOLS[index]
        else
          raise Card::Error, "not a valid stage index: #{index}"
        end
      end

      def stage_index stage
        case stage
        when Symbol
          INDECES[stage]
        when Integer
          stage
        when nil
          -1
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
        @current_stage_index > stage_index(stage)
      end

      def reset_stage
        @current_stage_index = -1
      end

      private

      def previous_stage_index from_stage=nil
        from_stage ||= @current_stage_index
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
        test_stage ||= @current_stage_index
        yield stage_index(reference_stage), stage_index(test_stage)
      end
    end
  end
end
