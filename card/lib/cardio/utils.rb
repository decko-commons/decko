module Cardio
  # Utilities that may need to be run even when mods are not loaded.
  module Utils
    class << self
      def empty_trash
        delete_trashed_files
        Card.where(trash: true).in_batches.update_all(left_id: nil, right_id: nil)
        Card.where(trash: true).in_batches.delete_all
        Card::Action.delete_cardless
        Card::Change.delete_actionless
        Card::Act.delete_actionless
        Card::Reference.clean
      end

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

      # deletes any file not associated with a real card.
      def delete_trashed_files
        dir = Cardio.paths["files"].existent.first
        # TODO: handle cloud files
        return unless dir

        (all_trashed_card_ids & all_file_ids).each do |file_id|
          delete_files_with_id dir, file_id
        end
      end

      def delete_files_with_id dir, file_id
        raise Card::Error, t(:core_exception_almost_deleted) if Card.exist?(file_id)

        ::FileUtils.rm_rf "#{dir}/#{file_id}", secure: true
      end

      def delete_tmp_files id=nil
        dir = [files_dir, "tmp", id.to_s].compact.join "/"
        FileUtils.rm_rf dir, secure: true
      end

      def files_dir
        @files_dir ||= Cardio.paths["files"].existent.first
      end

      def all_file_ids
        dir = Card.paths["files"].existent.first
        Dir.entries(dir)[2..].map(&:to_i)
      end

      def all_trashed_card_ids
        trashed_card_sql = %( select id from cards where trash is true )
        sql_results = Card.connection.select_all(trashed_card_sql)
        sql_results.map(&:values).flatten.map(&:to_i)
      end
    end
  end
end
