module Kaminari
  module Helpers
    class Tag
      include Patches::Kaminari::Helpers::Tag
    end
  end
end

if defined? BetterErrors
  module BetterErrors
    class StackFrame
      suppress_warnings { include Patches::BetterErrors::StackFrame::TmpPath }
    end
  end
end

class ActiveRecord::Relation
  include Patches::ActiveRecord::Relation
end

module ActiveJob::Arguments
  class << self
    prepend Patches::ActiveJob::Arguments
  end
end

#module ActionDispatch
#  class Reloader
#    extend Patches::ActionDispatch::Reloader
#  end
#end
