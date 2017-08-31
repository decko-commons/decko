module Patches
  class ActionDispatch
    class Reloader
      class << self
        def cleanup!
          Rails.application.reloader.reload!
        end

        def prepare!
          Rails.application.reloader.prepare!
        end
      end
    end
  end
end

