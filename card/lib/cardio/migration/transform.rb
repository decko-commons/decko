require "cardio/migration"

module Cardio
  class Migration
    class Transform < Migration
      @migration_type = :transform

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
        mode do
          Card::Auth.as_bot do
            yield
          ensure
            ::Card::Cache.reset_all
          end
        end
      end
    end
  end
end
