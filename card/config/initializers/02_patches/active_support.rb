module Patches
  module ActiveSupport
    module Callbacks
      module Callback
        def applies? object
          conditions_lambdas.all? {|c| c.call(object, nil)}
        end
      end
    end
  end
end
