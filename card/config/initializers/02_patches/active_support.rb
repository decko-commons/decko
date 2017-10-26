module Patches
  module ActiveSupport
    module Callbacks
      # Add applies? method to rails' callback api.
      # Used for events.
      module Callback
        def applies? object
          conditions_lambdas.all? { |c| c.call(object, nil) }
        end
      end
    end
  end
end
