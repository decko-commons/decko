class Card
  module Set
    class Event
      module Callbacks
        def set_event_callbacks
          %i[before after around].each do |kind|
            next unless (object_method = @opts.delete kind)
            set_event_callback object_method, kind
          end
        end

        def set_event_callback object_method, kind
          Card.class_exec(self) do |event|
            set_callback object_method, kind, event.name,
                         prepend: true, if: proc { |c| c.event_applies?(event) }
          end
        end
      end
    end
  end
end
