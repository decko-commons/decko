module Patches
  class ActionDispatch
    # needed to make rails-dev-tweaks gem to work with rails 5
    # based on this PR https://github.com/wavii/rails-dev-tweaks/pull/25/files
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

