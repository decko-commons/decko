require "pry"

DATA_ENVIRONMENTS = %i[production development test].freeze

module Cardio
  class Mod
    class Data
      include Card::Model::SaveHelper

      def initialize mod: nil
        @mod = mod
      end

      def merge
        Card::Mailer.perform_deliveries = false
        Card::Auth.as_bot do
          # puts Rails.env
          items.each { |item| ensure_card item }
        end
      end

      # list of card attribute hashes
      # @return [Array <Hash>]
      def items
        mods.map { |mod| mod_data mod }.flatten
      end

      # @return [Array <Card::Mod>]
      def mods
        mod_candidates.select { |m| Dir.exist? m.data_path }
      end

      private

      # @return [Array <Card::Mod>]
      def mod_candidates
        @mod ? [Mod.dirs.fetch_mod(@mod)].compact : Mod.dirs.mods
      end

      # @return [Array <Hash>]
      def mod_data mod
        environments.map do |env|
          filename = File.join mod.data_path, "#{env}.yml"
          YAML.load_file filename if File.exist? filename
        end.compact
      end

      # @return [Array <Symbol>]
      # holarchical. each includes the previous
      # production = [:production],
      # development = [:production, :development], etc.
      def environments
        index = DATA_ENVIRONMENTS.index(Rails.env.to_sym) || -1
        DATA_ENVIRONMENTS[0..index]
      end
    end
  end
end
