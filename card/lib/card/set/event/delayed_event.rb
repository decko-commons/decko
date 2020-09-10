require "application_job"

class Card
  # attributes that ActiveJob can handle
  def serializable_attributes
    self.class.action_specific_attributes + set_specific.keys
  end

  module Set
    class Event
      module DelayedEvent
        DELAY_STAGES = ::Set.new(%i[integrate_with_delay_stage
                                    integrate_with_delay_final_stage]).freeze

        def priority
          @priority || 10
        end

        private

        def process_delayed_job_opts opts
          @priority = opts.delete :priority
        end

        def with_delay? opts
          DELAY_STAGES.include?(opts[:after]) || DELAY_STAGES.include?(opts[:before])
        end

        def define_delayed_event_method
          define_event_delaying_method
          define_standard_event_method delaying_method_name
        end

        # creates a method that creates an ActiveJob that calls the event method.
        # The scheduled job gets the card object as argument and all serializable
        # attributes of the card.
        # (when the job is executed ActiveJob fetches the card from the database
        # so all attributes get lost)
        # It uses the event as queue name
        def define_event_delaying_method
          @set_module.class_exec(self) do |event|
            define_method(event.delaying_method_name, proc do
              IntegrateWithDelayJob
                .set(set_delayed_job_args(event))
                .perform_later(*perform_delayed_job_args(event))
            end)
          end
        end

        class IntegrateWithDelayJob < ApplicationJob
          def perform act_id, card, card_attribs, env, auth, method_name
            handle_perform do
              load_card card, card_attribs
              Director.contextualize_delayed_event act_id, card, env, auth do
                card.send method_name
              end
            end
          end

          def handle_perform
            yield
          rescue StandardError => error
            Card::Error.report error, @card
            raise error
          ensure
            Director.expire
          end

          def load_card card, card_attribs
            @card = card
            Card::Cache.renew
            card.deserialize_for_active_job! card_attribs
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

  private

  def set_delayed_job_args event
    { queue: event.name, priority: event.priority }
  end

  def perform_delayed_job_args event
    [Card::Director.act&.id,
     self,
     serialize_for_active_job,
     Card::Env.serialize,
     Card::Auth.serialize,
     event.simple_method_name]
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
      { value: serialize_hash_value(value), type: "hash" }
    when ActionController::Parameters
      serialize_value value.to_unsafe_h
    else
      { value: value }
    end
  end

  def serialize_hash_value value
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
