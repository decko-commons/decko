module Cardio
  class Migration
    # methods for porting migrations from old table to new table
    module Port

      def port_all
        %i[schema transform].each do |type|
          migration_class(type).port
        end
      end

      def port
        return unless lease_connection.table_exists? old_deck_table
        rename_old_tables
        lease_connection.execute "INSERT INTO #{table} (#{select_nonduplicate_versions})"
        lease_connection.drop_table old_deck_table
      end

      private

      def select_nonduplicate_versions
        "SELECT * FROM #{old_deck_table} o WHERE NOT EXISTS " \
          "(SELECT * FROM #{table} n WHERE o.version = n.version)"
      end

      def rename_old_tables
        old_tables.each do |old_table_name|
          next unless lease_connection.table_exists? old_table_name
          lease_connection.rename_table old_table_name, table
        end
      end

      def lease_connection
         ActiveRecord::Base.lease_connection
      end
    end
  end
end
