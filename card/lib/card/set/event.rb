class Card
  def deserialize_for_active_job! attr
    attr.each do |attname, args|
      # symbols are not allowed so all symbols arrive here as strings
      # convert strings that were symbols before back to symbols
      value = deserialize_value args[:value], args[:type]
      instance_variable_set("@#{attname}", value)
    end

    include_set_modules
  end

  def with_env_and_auth env, auth
    # If active jobs (and hence the integrate_with_delay events) don't run
    # in a background process then Card::Env.deserialize! decouples the
    # controller's params hash and the Card::Env's params hash with the
    # effect that params changes in the CardController get lost
    # (a crucial example are success params that are processed in
    # CardController#update_params_for_success)
    return yield if Decko.config.active_job.queue_adapter == :inline
    Card::Auth.with auth do
      Card::Env.with env do
        yield
      end
    end
  end

  def serialize_for_active_job
    serializable_attributes.each_with_object({}) do |name, hash|
      value = instance_variable_get("@#{name}")
      hash[name] = serialize_value value
    end
  end

  def serialize_value value
    # ActiveJob doesn't accept symbols and Time as arguments
    case value
    when Symbol
      { value: value.to_s, type: "symbol" }
    when Time
      { value: value.to_s, type: "time" }
    when Hash
      {
        value: value.each_with_object({}) { |(k, v), h| h[k] = serialize_value(v) },
        type: "hash"
      }
    else
      { value: value }
    end
  end

  def deserialize_value val, type
    case type
    when "symbol"
      val.to_sym
    when "time"
      DateTime.parse val
    when "hash"
      val.each_with_object({}) do |(k, v), h|
        h[k] = deserialize_value v[:value], v[:type]
      end
    else
      val
    end
  end

  def log_event_call event
    Rails.logger.debug "#{name}: #{event}"
    # puts "#{name}: #{event}"
    # puts "#{Card::ActManager.to_s}".green
  end

  module Set
    # Implements the event API for card sets
    module Event
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
          delaying_method = "#{event}_with_delay"
          define_event_delaying_method event, delaying_method, final_method_name
          final_method_name = delaying_method
        end
        define_event_method event, final_method_name
      end

      def with_delay? opts
        opts[:after] == :integrate_with_delay_stage ||
          opts[:before] == :integrate_with_delay_stage
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

      # creates an ActiveJob.
      # The scheduled job gets the card object as argument and all serializable
      # attributes of the card.
      # (when the job is executed ActiveJob fetches the card from the database
      # so all attributes get lost)
      # @param event [String] the event used as queue name
      # @param method_name [String] the name of the method we define to trigger
      #   the actjve job
      # @param final_method_name [String] the name of the method that get called
      #   by the active job and finally executes the event
      def define_event_delaying_method event, method_name, final_method_name
        class_eval do
          define_method(method_name, proc do
            IntegrateWithDelayJob.set(queue: event).perform_later(
              self, serialize_for_active_job, Card::Env.serialize,
              Card::Auth.serialize, final_method_name
            )
          end)
        end
      end

      class IntegrateWithDelayJob < ApplicationJob
        def perform card, card_attribs, env, auth, method_name
          card.deserialize_for_active_job! card_attribs
          card.with_env_and_auth env, auth do
            card.send method_name
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
