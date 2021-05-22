module Cardio
  class Migration
    class Import
      # executes the card import
      class Merger
        def initialize data_path, opts={}
          @data_path = data_path
          @output_path = File.join data_path, "unmerged"
          @data = ImportData.load @data_path, opts
        end

        def merge
          puts("nothing to merge") && return if @data.empty?

          without_mail_deliveries do
            Card::Auth.as_bot do
              Card.merge_list @data, output_file: @output_path
            end

            update_import_data
          end
        end

        private

        def without_mail_deliveries
          m = Card::Mailer
          prior = m.perform_deliveries
          m.perform_deliveries = false
          yield
        ensure
          m.perform_deliveries = prior
        end

        def update_import_data
          update_time = Time.zone.now.to_s
          ImportData.update(@data_path) do |import_data|
            @data.each do |card_data|
              import_data.merged card_data, update_time
            end
          end
        end
      end
    end
  end
end
