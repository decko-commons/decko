require "cardio/migration"

module Cardio
  class Migration
    # for migrations involving database schema definitions
    class Schema < Migration
      @migration_type = :schema
      @old_tables = []
      @old_deck_table = "schema_migrations_deck"
    end
  end
end
