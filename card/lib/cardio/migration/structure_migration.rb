require "cardio/migration"

module Cardio
  class Migration
    class StructureMigration < Migration
      @migration_type = :structure
    end
  end
end
