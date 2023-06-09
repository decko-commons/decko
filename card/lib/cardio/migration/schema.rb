require "cardio/migration"

module Cardio
  class Migration
    class Schema < Migration
      @migration_type = :schema
      @old_tables = []
      @old_deck_table = "schema_migrations_deck"
    end
  end
end
