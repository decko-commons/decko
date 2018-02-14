class Card
  module Set
    module Event
      module DelayedEvent
        DELAY_STAGES = ::Set.new([:integrate_with_delay_stage,
                                  :integrate_with_delay_final_stage]).freeze

        private

        def with_delay? opts
          DELAY_STAGES.include?(opts[:after]) || DELAY_STAGES.include?(opts[:before])
        end

        def define_delayed_event_method event, simple_method_name
          delaying_method = "#{event}_with_delay"
          define_event_delaying_method event, delaying_method, simple_method_name
          define_standard_event_method event, delaying_method
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
                Card::ActManager.act&.id, self, serialize_for_active_job, Card::Env.serialize,
                Card::Auth.serialize, final_method_name
              )
            end)
          end
        end

        class IntegrateWithDelayJob < ApplicationJob
          def perform act_id, card, card_attribs, env, auth, method_name
            card.deserialize_for_active_job! card_attribs
            ActManager.contextualize_delayed_event act_id, card, env, auth do
              card.send method_name
            end
          end
        end
      end
    end
  end

  def deserialize_for_active_job! attr
    attr.each do |attname, val|
      instance_variable_set("@#{attname}", val)
    end
    include_set_modules
  end

  def serialize_for_active_job
    serializable_attributes.each_with_object({}) do |name, hash|
      hash[name] = instance_variable_get("@#{name}")
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
      { value: serialize_hash_value(value), type: "hash"}
    when ActionController::Parameters
      serialize_value value.to_unsafe_h
    else
      { value: value }
    end
  end

  def serialize_hash_value
    value.each_with_object({}) { |(k, v), h| h[k] = serialize_value(v) }
  end

  def deserialize_value val, type
    case type
    when "symbol"
      val.to_sym
    when "time"
      DateTime.parse val
    when "hash"
      deserialize_hash_value val
    else
      val
    end
  end

  def deserialize_hash_value value
    value.each_with_object({}) do |(k, v), h|
      h[k] = deserialize_value v[:value], v[:type]
    end
  end
end
