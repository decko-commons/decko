# -*- encoding : utf-8 -*-

module Cardio
  class Migration < ActiveRecord::Migration[6.1]
    include Card::Model::SaveHelper unless ENV["NO_CARD_LOAD"]

    class << self
      # Rake tasks use class methods, migrations use instance methods.
      # To avoid repetition a lot of instance methods here just call class
      # methods.
      # The subclass Card::CoreMigration needs a different @type so we can't use a
      # class variable @@type. It has to be a class instance variable.
      # Migrations are subclasses of Cardio::Migration or Card::CoreMigration
      # but they don't inherit the @type. The method below solves this problem.
      def migration_type
        @migration_type || ancestors[1]&.migration_type
      end

      def find_unused_name base_name
        test_name = base_name
        add = 1
        while Card.exists?(test_name)
          test_name = "#{base_name}#{add}"
          add += 1
        end
        test_name
      end

      def migration_paths mig_type=migration_type
        Schema.migration_paths mig_type
      end

      def assume_migrated_upto_version
        Schema.assume_migrated_upto_version migration_type
      end

      def assume_current
        migration_context do |mc|
          versions = mc.migrations.map(&:version)
          migrated = mc.get_all_versions
          to_mark = versions - migrated
          mark_as_migrated to_mark if to_mark.present?
        end
      end

      def data_path filename=nil
        File.join([migration_paths.first, "data", filename].compact)
      end

      private

      def mark_as_migrated versions
        sql = connection.send :insert_versions_sql, versions
        connection.execute sql
      end

      def connection
        ActiveRecord::Base.connection
      end

      def migration_context &block
        Schema.migration_context migration_type, &block
      end
    end

    def contentedly
      return yield if ENV["NO_CARD_LOAD"]
      Card::Cache.reset_all
      Schema.mode "" do
        Card::Auth.as_bot do
          yield
        ensure
          ::Card::Cache.reset_all
        end
      end
    end

    def data_path filename=nil
      self.class.data_path filename
    end

    # Execute this migration in the named direction
    # copied from ActiveRecord to wrap 'up' in 'contentedly'
    def exec_migration conn, direction
      @connection = conn
      if respond_to?(:change)
        if direction == :down
          revert { change }
        else
          change
        end
      else
        contentedly { send(direction) }
      end
    ensure
      @connection = nil
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end
  end
end

