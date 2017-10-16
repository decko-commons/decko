class Card
  def log_event_call event
    Rails.logger.debug "#{name}: #{event}"
    # puts "#{name}: #{event}"
    # puts "#{Card::ActManager.to_s}".green
  end

  module Set
    # Implements the event API for card sets
    module Event
      include DelayedEvent

      def event event, stage_or_opts={}, opts={}, &final
        if stage_or_opts.is_a? Symbol
          opts[:in] = stage_or_opts
        else
          opts = stage_or_opts
        end
        process_stage_opts opts

        Card.define_callbacks event
        define_event event, opts, &final
        set_event_callbacks event, opts
      end

      private

      def define_event event, opts, &final
        final_method_name = "#{event}_without_callbacks" # should be private?
        class_eval do
          define_method final_method_name, &final
        end

        if with_delay? opts
          define_delayed_event_method event, final_method_name
        else
          define_event_method event, final_method_name
        end
      end

      def with_delay? opts
        DELAY_STAGES.include?(opts[:after]) || DELAY_STAGES.include?(opts[:before])
      end

      def process_stage_opts opts
        if opts[:after] || opts[:before]
          # ignore :in options
        elsif opts[:in]
          opts[:after] =
            callback_name opts.delete(:in), opts.delete(:after_subcards)
        end
        opts[:on] = [:create, :update] if opts[:on] == :save
      end

      def callback_name stage, after_subcards=false
        name = after_subcards ? "#{stage}_final_stage" : "#{stage}_stage"
        name.to_sym
      end

      def define_event_method event, call_method
        class_eval do
          define_method event do
            log_event_call event
            run_callbacks event do
              send call_method
            end
          end
        end
      end

      def set_event_callbacks event, opts
        opts[:set] ||= self
        [:before, :after, :around].each do |kind|
          next unless (object_method = opts.delete(kind))
          Card.class_eval do
            set_callback(
              object_method, kind, event,
              prepend: true, if: proc { |c| c.event_applies?(opts) }
            )
          end
        end
      end
    end
  end
end
