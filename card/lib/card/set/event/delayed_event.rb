class Card
  # attributes that ActiveJob can handle
  #
  # supercard and superleft are excluded, because it caused issues to have them in
  # delayed job but not fully restored (set modules not included, attributes not retained,
  # etc.) Since we're supposed to have an actual _left_ by the integrate_with_delay
  # stage, it's not clear that they're needed. But if we revisit and find they _are_
  # needed, then we clearly need to make sure that they are fully restored. At a bare
  # minimum they would need to include set modules.
  def serializable_attributes
    self.class.action_specific_attributes + set_specific.keys -
      %i[supercard superleft subcards]
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
          opts.delete(:delay) ||
            DELAY_STAGES.intersect?([opts[:after], opts[:before]].to_set)
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

        class IntegrateWithDelayJob < Cardio::Job
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
          rescue StandardError => e
            Card::Error.report e, @card
            raise e
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
    value.transform_values { |v| serialize_value(v) }
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
    value.transform_values do |v|
      deserialize_value v[:value], v[:type]
    end
  end
end
