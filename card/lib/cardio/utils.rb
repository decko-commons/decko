module Cardio
  # Utilities that may need to be run even when mods are not loaded.
  module Utils
    class << self
      def seed_test_db
        system "env RAILS_ENV=test bundle exec rake db:seed:replant"
      end

      # deletes tmp directory within files directory
      # It's here because it gets called as part of cache clearing, which sometimes gets
      # called in a context where card mods are not loaded.
      # Why does cache clearing need to do this??
      def delete_tmp_files! id=nil
        raise "no files directory" unless files_dir

        delete_tmp_files id
      rescue StandardError
        Rails.logger.info "failed to remove tmp files"
      end

      private

      def delete_tmp_files id=nil
        dir = [files_dir, "tmp", id.to_s].compact.join "/"
        FileUtils.rm_rf dir, secure: true
      end

      def files_dir
        @files_dir ||= Cardio.paths["files"].existent.first
      end
    end
  end
end
