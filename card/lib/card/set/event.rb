class Card
  module Set
    # Events are the building blocks of the three transformative card actions: _create_, _update_, and _delete_. (The fourth kind of action, _read_, does not transform cards, and is associated with {Card::Format views}, not events).
    #
    # Whenever you create, update, or delete a card, the card goes through three phases:
    #   * __validation__ makes sure all the data is in order
    #   * __storage__ puts the data in the database
    #   * __integration__ deals with any ramifications of those changes
    #
    #
    module Event
      include DelayedEvent

      def event event, stage_or_opts={}, opts={}, &final
        opts = event_opts stage_or_opts, opts
        Card.define_callbacks event
        define_event event, opts, &final
        set_event_callbacks event, opts
      end

      private

      # EVENT OPTS

      def event_opts stage_or_opts, opts
        opts = normalize_opts stage_or_opts, opts
        process_stage_opts opts
        process_action_opts opts
        opts
      end

      def normalize_opts stage_or_opts, opts
        if stage_or_opts.is_a? Symbol
          opts[:in] = stage_or_opts
        else
          opts = stage_or_opts
        end
        opts
      end

      def process_action_opts opts
        opts[:on] = [:create, :update] if opts[:on] == :save
      end

      def process_stage_opts opts
        if opts[:after] || opts[:before]
          # ignore :in options
        elsif (in_opt = opts.delete :in)
          opts[:after] = callback_name in_opt, opts.delete(:after_subcards)
        end
      end

      def callback_name stage, after_subcards=false
        name = after_subcards ? "#{stage}_final_stage" : "#{stage}_stage"
        name.to_sym
      end

      # EVENT DEFINITION

      def define_event event, opts, &final
        simple_method_name = "#{event}_without_callbacks"
        define_simple_method event, simple_method_name, &final
        define_event_method event, simple_method_name, opts
      end

      def define_simple_method _event, method_name, &method
        class_eval do
          define_method method_name, &method
        end
      end

      def define_event_method event, method_name, opts
        event_type = with_delay?(opts) ? :delayed : :standard
        send "define_#{event_type}_event_method", event, method_name
      end

      def define_standard_event_method event, method_name
        class_eval do
          define_method event do
            log_event_call event
            run_callbacks event do
              send method_name
            end
          end
        end
      end

      # EVENT CALLBACKS

      def set_event_callbacks event, opts
        opts[:set] ||= self
        [:before, :after, :around].each do |kind|
          next unless (object_method = opts.delete kind)
          set_event_callback object_method, kind, event, opts
        end
      end

      def set_event_callback object_method, kind, event, opts
        Card.class_eval do
          set_callback object_method, kind, event,
                       prepend: true, if: proc { |c| c.event_applies?(opts) }
        end
      end
    end
  end

  def log_event_call event
    Rails.logger.debug "#{name}: #{event}"
    # puts "#{name}: #{event}"
    # puts "#{Card::ActManager.to_s}".green
  end
end
