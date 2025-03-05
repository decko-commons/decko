class Card
  module Set
    class Event
      # opt into (trigger) or out of (skip) events
      module SkipAndTrigger
        settings = [
          :skip,                        # [Array] skip event(s) for all cards in act
          :skip_in_action,              # [Array] skip event for just this card
          :trigger,                     # [Array] trigger event(s) for all cards in act
          :trigger_in_action            # [Array] trigger event for just this card
        ]
        attr_reader(*settings)

        Card.action_specific_attributes +=
          settings + %i[skip_hash full_skip_hash trigger_hash full_trigger_hash]

        def skip= skip_val
          @skip_hash = @full_skip_hash = nil
          @skip = skip_val
        end

        def skip_in_action= skip_val
          @skip_hash = @full_skip_hash = nil
          @skip_in_action = skip_val
        end

        def trigger= trigger_val
          @trigger_hash = @full_trigger_hash = nil
          @trigger = trigger_val
        end

        def trigger_in_action= trigger_val
          @trigger_hash = @full_trigger_hash = nil
          @trigger_in_action = trigger_val
        end

        # force skipping this event for all cards in act
        def skip_event! *events
          @full_skip_hash = nil
          force_events events, act_skip_hash
        end

        # force skipping this event for this card only
        def skip_event_in_action! *events
          force_events events, full_skip_hash
        end

        # force triggering this event (when it comes up) for all cards in act
        def trigger_event! *events
          @full_trigger_hash = nil
          force_events events, act_trigger_hash
        end

        # force triggering this event (when it comes up) for this card only
        def trigger_event_in_action! *events
          force_events events, full_trigger_hash
        end

        # hash form of raw skip setting, eg { "my_event" => true }
        def skip_hash
          @skip_hash ||= hash_with_value skip, true
        end

        def trigger_hash
          @trigger_hash ||= hash_with_value trigger, true
        end

        def skip_event? event
          full_skip_hash.key? event.to_s
        end

        def trigger_event? event
          full_trigger_hash.key? event.to_s
        end

        private

        # "applies always means event can run
        # so if skip_condition_applies?, we do NOT skip
        def skip_condition_applies? event, allowed
          return true unless (val = full_skip_hash[event.name.to_s])

          allowed ? val.blank? : (val != :force)
        end

        def trigger_condition_applies? event, required
          return true unless required

          full_trigger_hash[event.name.to_s].present?
        end

        def full_skip_hash
          @full_skip_hash ||= act_skip_hash.merge hash_with_value(skip_in_action, true)
        end

        def act_skip_hash
          (act_card || self).skip_hash
        end

        def full_trigger_hash
          @full_trigger_hash ||=
            act_trigger_hash.merge hash_with_value(trigger_in_action, true)
        end

        def act_trigger_hash
          (act_card || self).trigger_hash
        end

        def hash_with_value array, value
          Array.wrap(array).each_with_object({}) do |event, hash|
            hash[event.to_s] = value
          end
        end

        def force_events events, hash
          events.each { |e| hash[e.to_s] = :force }
        end
      end
    end
  end
end
