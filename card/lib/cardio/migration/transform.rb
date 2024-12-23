require "cardio/migration"

module Cardio
  class Migration
    # for migrations involving data transformations (but not schema changes)
    class Transform < Migration
      include Card::Model::SaveHelper unless ENV["NO_CARD_LOAD"]

      @migration_type = :transform
      @old_tables = %w[schema_migrations_core_cards schema_migrations_cards]
      @old_deck_table = "schema_migrations_deck_cards"

      private

      def with_migration_table
        self.table_name = "transform_migrations"
        yield
      ensure
        self.table_name = "schema_migrations"
      end

      # Execute this migration in the named direction
      # override ActiveRecord to wrap 'up' in 'contentedly'
      def exec_migration conn, direction
        return super if respond_to? :change

        @connection = conn
        contentedly { send direction }
      ensure
        @connection = nil
      end

      def contentedly
        return yield if ENV["NO_CARD_LOAD"]

        Card::Cache.reset_all
        Card::Auth.as_bot do
          yield
        ensure
          ::Card::Cache.reset_all
        end
      end
    end
  end
end
