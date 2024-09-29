module Cardio
  class Mod
    # The Sow class is for exporting data to mods' data directories so that they can
    # be used as seed data when the mod is installed.
    #
    # https://docs.google.com/document/d/13K_ynFwfpHwc3t5gnLeAkZJZHco1wK063nJNYwU8qfc/edit#
    class Sow
      include YamlDump
      include CardSource
      include RemoteSource

      def initialize **args
        @mod = args[:mod]
        @name = args[:name]
        @cql = args[:cql]
        @url = args[:url]
        @remote = args[:remote]
        @podtype = args[:podtype] || (Rails.env.test? ? :test : :real)
        @items = args[:items]
        @field_tags = args[:field_tags]
      end

      # if output mod given,
      def out
        Card::Cache.reset_all
        @mod ? dump(output_hash) : puts(new_data.to_yaml.yellow)
        :success
      rescue Card::Error::NotFound => e
        e.message
      rescue JSON::ParserError => e
        e.message
      end

      private

      def output_hash
        if target.present?
          merge_data
          target
        else
          new_data
        end
      end

      # @return [Array <Hash>]
      def new_data
        @new_data ||= fetch_new_data
      end

      def fetch_new_data
        remote_source ? pod_from_url : new_data_from_cards
      end

      def merge_data
        new_data.each do |item|
          if (index = target_index item)
            target[index] = item
          else
            target << item
          end
        end
      end

      def target
        @target ||= (old_data || nil)
      end

      def target_index new_item
        new_code = new_item[:codename]
        new_name = new_item[:name].to_name
        target.find_index do |t|
          t.is_a?(Hash) &&
            ((new_code.present? && (new_code == t[:codename])) ||
              (t[:name].to_name == new_name))
        end
      end

      def old_data
        return unless File.exist? filename
        parse_pod_yaml File.read(filename)
      end

      def parse_pod_yaml pod_yaml
        YAML.safe_load pod_yaml, permitted_classes: [Symbol]
      end
    end
  end
end
