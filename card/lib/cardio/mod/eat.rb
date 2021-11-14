require "timecop"

DATA_ENVIRONMENTS = %i[production development test].freeze

module Cardio
  class Mod
    # import data from data directory of mods
    # (list of card attributes)
    # https://docs.google.com/document/d/13K_ynFwfpHwc3t5gnLeAkZJZHco1wK063nJNYwU8qfc/edit#
    class Eat
      include Card::Model::SaveHelper

      def initialize mod: nil, env: nil, user: nil, verbose: nil
        @mod = mod
        @env = env
        @user_id = user&.card_id
        @verbose = !verbose.nil?
      end

      def up
        Card::Mailer.perform_deliveries = false
        Card::Auth.as_bot do
          items.each do |item|
            track do
              # # FIXME: should not have to clear cache or handle delayed jobs.
              # # Without this relationship metrics are not getting added correctly.
              # Card::Cache.reset
              # Delayed::Worker.new.work_off
              #
              current_user item.delete(:user)
              time_machine item.delete(:time) do
                ensure_card item
              end
            end
          end
        end
      end

      # list of card attribute hashes
      # @return [Array <Hash>]
      def items
        paths.map { |mod_path| mod_items mod_path }.flatten
      end

      # @return [Array <String>]
      def paths
        hash = Mod.dirs.subpaths "data"
        @mod ? mod_paths(hash[@mod]) : hash.values
      end

      private

      def time_machine value, &block
        return yield unless value.present?
        Timecop.freeze Time.at(time_integer(value)), &block
      end

      def time_integer value
        return value unless value.match?(/^[+-]/)

        eval "#{Time.now.to_i} #{value}"
      end

      def current_user item_user
        Card::Auth.current_id = item_user&.card_id || @user_id || Card::WagnBotID
      end

      def track
        card = yield
        puts "eaten: #{card.name}".green if @verbose
      rescue StandardError => e
        puts e.message.red
        puts e.backtrace.join("\n") if @verbose
      end

      def mod_paths path
        return [path] if path && File.exist?(path)

        raise "no data directory found for mod #{@mod}".red
      end

      # @return [Array <Hash>]
      def mod_items mod_path
        environments.map do |env|
          filename = File.join mod_path, "#{env}.yml"
          next unless File.exist? filename

          handle_files mod_path do
            YAML.load_file filename
          end
        end.compact
      end

      def handle_files mod_path
        items = yield
        items.each do |item|
          next unless (filename = item[:file])

          item[:file] = File.open File.join(mod_path, "files", filename)
        end
      end

      # @return [Array <Symbol>]
      # holarchical. each includes the previous
      # production = [:production],
      # development = [:production, :development], etc.
      def environments
        index = DATA_ENVIRONMENTS.index(@env&.to_sym || Rails.env.to_sym) || -1
        DATA_ENVIRONMENTS[0..index]
      end
    end
  end
end
