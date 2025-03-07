class Card
  module Set
    class Event
      # handle card event callbacks
      module Callbacks
        def set_event_callbacks
          %i[before after around].each do |kind|
            next unless (object_method = @opts.delete kind)

            set_event_callback object_method, kind
          end
        end

        def set_event_callback object_method, kind
          valid_event_callback kind, object_method do
            Card.class_exec(self) do |event|
              set_callback object_method, kind, event.name,
                           prepend: true, if: proc { |c| c.event_applies?(event) }
            end
          end
        end

        def valid_event_callback kind, method
          yield
        rescue NoMethodError
          raise "invalid event callback: `#{kind}: #{method}`"
        end
      end
    end
  end
end
