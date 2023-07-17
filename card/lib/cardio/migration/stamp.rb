module Cardio
  class Migration
    # methods for stamping migration versions to files
    module Stamp
      def stamp
        mode do
          return unless (version = stampable_version) && (file = stamp_file)
          puts ">>  writing version: #{version} to #{file.path}"
          file.puts version
        end
      end

      private

      def stamp_file
        ::File.open stamp_path, "w"
      end

      def stampable_version
        version = ActiveRecord::Migrator.current_version
        version.to_i.positive? && version
      end

      def stamp_path
        stamp_dir = ENV["SCHEMA_STAMP_PATH"] || File.join(Cardio.root, "db")

        File.join stamp_dir, "version_#{migration_type}.txt"
      end
    end
  end
end
