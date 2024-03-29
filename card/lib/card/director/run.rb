class Card
  class Director
    # methods for running stages
    module Run
      def catch_up_to_stage next_stage
        return if @delay && before?(:integrate_with_delay, next_stage)

        upto_stage(next_stage) do |stage|
          run_stage stage
        end
      end

      def run_delayed_event act
        @running = true
        @act = act
        @current_stage_index = stage_index :integrate_with_delay
        yield
        run_subcard_stages :integrate_with_delay
      end

      def delay!
        @delay = true
      end

      def restart
        @running = false
        @current_stage_index = nil
      end

      private

      def run_stage stage, &block
        return true unless valid_next_stage? stage

        # puts "#{@card.name}: #{stage} stage".yellow
        @current_stage_index = stage_index stage
        handle_stage stage, block do
          run_stage_callbacks stage
          run_subcard_stages stage
          run_final_stage_callbacks stage
        end
      end

      def handle_stage stage, block
        case stage
        when :initialize
          prepare_for_phases
        when :store
          # in the store stage it can be necessary that
          # other subcards must be saved before we save this card
          return store(&block)
        end
        yield
      end

      def run_stage_callbacks stage, callback_postfix=""
        Rails.logger.debug "#{stage}: #{@card.name}"
        # we use abort :success in the :store stage for :save_draft

        callbacks = :"#{stage}#{callback_postfix}_stage"
        if in_or_before?(:store, stage) && !main?
          @card.abortable { @card.run_callbacks callbacks }
        else
          @card.run_callbacks callbacks
        end
      end

      def run_subcard_stages stage
        each_subcard_director stage do |subdir|
          condition = block_given? ? yield(subdir) : true
          subdir.catch_up_to_stage stage if condition
        end
      end

      def each_subcard_director stage
        subdirectors.each do |subdir|
          yield subdir unless subdir.head? && before?(:integrate, stage)
        end
      ensure
        @card.handle_subcard_errors
      end

      def run_final_stage_callbacks stage
        run_stage_callbacks stage, "_final"
      end

      def upto_stage stage
        @current_stage_index ||= -1
        (@current_stage_index + 1).upto(stage_index(stage)) do |i|
          yield stage_symbol(i)
        end
      end

      def valid_next_stage? next_stage
        @current_stage_index ||= -1
        return false if @abort ||
                        in_or_after?(next_stage) ||
                        ahead_of_parent?(next_stage) ||
                        !valid_card?(next_stage)

        check_skipped_stage next_stage
        true
      end

      def valid_card? next_stage
        @card.errors.empty? || in_or_before?(:validate, next_stage)
      end

      def check_skipped_stage stage
        return unless before? previous_stage_index(stage)

        raise Card::Error, "stage #{previous_stage_symbol stage} was " \
                           "skipped for card #{@card}"
      end

      def ahead_of_parent? next_stage
        head? ? false : after?(parent.current_stage_index, next_stage)
      end
    end
  end
end
