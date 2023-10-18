module Cardio
  class Migration
    # methods for assuming migration states
    module Assumption
      def assume_current
        context do |mc|
          versions = mc.migrations.map(&:version)
          migrated = mc.get_all_versions
          to_mark = versions - migrated
          mark_as_migrated to_mark if to_mark.present?
        end
      end

      def assume_migrated_upto_version version=nil
        mode do |_paths|
          version ||= self.version
          ActiveRecord::Schema.assume_migrated_upto_version version
        end
      end

      private

      def mark_as_migrated versions
        sql = connection.send :insert_versions_sql, versions
        connection.execute sql
      end
    end
  end
end
