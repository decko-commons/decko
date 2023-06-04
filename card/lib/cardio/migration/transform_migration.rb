require "cardio/migration"

module Cardio
  class Migration
    class TransformMigration < Migration
      @migration_type = :transform
    end
  end
end
