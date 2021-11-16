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
        Card::Cache.reset_all
        Card::Mailer.perform_deliveries = false
        Card::Auth.as_bot do
          items.each do |item|
            track do
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
        mods_with_data.map { |mod| mod_items mod }.flatten
      end

      private

      # @return [Array <Cardio::Mod>]
      def mods_with_data
        paths = Mod.dirs.subpaths "data"
        mod_names = @mod ? ensure_mod_data_path(paths) : paths.keys
        mod_names.map { |mod_name| Mod.fetch mod_name }
      end

      def ensure_mod_data_path paths
        return [@mod] if paths[@mod]

        raise "no data directory found for mod #{@mod}".red
      end

      def time_machine value, &block
        return yield unless value.present?

        Timecop.freeze Time.at(time_integer(value)), &block
      end

      def time_integer value
        case value
        when /^[+-]\d+$/
          # plus or minus an integer (safe to eval)
          eval "#{Time.now.to_i} #{value}", binding, __FILE__, __LINE__
        when Integer
          value
        else
          raise TypeError, "invalid time value: #{value}. accepts int, +int, and -int"
        end
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

      # @return [Array <Hash>]
      def mod_items mod
        environments.map { |env| items_for_environment mod, env }.compact
      end

      def items_for_environment mod, env
        return unless (items = items_from_yaml mod, env)

        if items.first.is_a? String
          items.map! { |filename| items_from_yaml mod, env, filename }
        end
        interpret_items mod, items
      end

      def interpret_items mod, items
        each_card_hash(items) { |hash| handle_attachments mod, hash }
      end

      def items_from_yaml mod, env, filename=nil
        source = "#{env}#{'/' if filename.present?}#{filename}.yml"
        return unless (path = mod.subpath "data", source)

        YAML.load_file path
      end

      def each_card_hash items
        items.each do |item|
          yield item
          item[:subfields]&.values&.each { |val| yield val if val.is_a? Hash }
        end
        items
      end

      def handle_attachments mod, hash
        attachments hash do |key, filename|
          hash[key] = mod_file mod, filename
          hash[:mod] = mod.name if hash[:storage_type] == :coded
        end
      end

      def attachments hash
        attachment_keys.each do |key|
          yield key, hash[key] if hash.key? key
        end
      end

      def mod_file mod, filename
        File.open mod.subpath("data/files", filename)
      end

      def attachment_keys
        @attachment_keys ||= Card.uploaders.keys
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
