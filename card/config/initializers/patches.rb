module Kaminari #:nodoc: all
  module Helpers
    class Tag
      include Patches::Kaminari::Helpers::Tag
    end
  end
end

if defined? BetterErrors
  module BetterErrors #:nodoc: all
    class StackFrame
      # suppress_warnings { include Patches::BetterErrors::StackFrame::TmpPath }
    end
  end
end

# ARDEP: need to isolate this to named and optionally included place
module ActiveRecord #:nodoc: all
  class Relation
    include Patches::ActiveRecord::Relation
  end

  class Migration
    class << self
      prepend Patches::ActiveRecord::Migration::ClassMethods
    end
  end

  module ConnectionAdapters
    class AbstractAdapter
      prepend Patches::ActiveRecord::ConnectionAdapters::AbstractAdapter
    end

    class PostgreSQLAdapter < AbstractAdapter
      prepend Patches::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
    end

    class AbstractMysqlAdapter < AbstractAdapter
    end

    class Mysql2Adapter < AbstractMysqlAdapter
      include Patches::ActiveRecord::ConnectionAdapters::Mysql2Adapter
    end

    class SQLiteAdapter < AbstractAdapter
      include Patches::ActiveRecord::ConnectionAdapters::SQLiteAdapter
    end
  end
end

module ActiveJob::Arguments #:nodoc: all
  class << self
    prepend Patches::ActiveJob::Arguments
  end
end

module ActionDispatch #:nodoc: all
  class Reloader
    extend Patches::ActionDispatch::Reloader
  end
end

module ActiveSupport #:nodoc: all
  module Callbacks
    class Callback
      prepend Patches::ActiveSupport::Callbacks::Callback
    end
  end
end


module Zeitwerk #:nodoc: all
  class Loader
    prepend Patches::Zeitwerk
  end
end
