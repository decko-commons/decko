require_relative "import/import_data"
require_relative "import/merger"

module Cardio
  class Migration
    # Imports card data from a local or remote deck
    #
    # The cards' content for the import is stored for every card in a separate
    # file, other attributes like name or type are stored for all cards together
    # in a yml file.
    #
    # To update a card's content you only have to change the card's content
    # file. The merge method will recognize that the file was changed
    # since the last merge and merge it into the cards table
    # To update other attributes change them in the yml file and either remove
    # the 'merged' value or touch the corresponding content file
    class Import
      def initialize data_path
        @data_path = data_path
      end

      # Merge the import data into the cards table.
      # Bu default it merges only the data that was changed or added
      # since the last merge.
      # @param [Hash] opts choose which cards to merge
      # @option opts [Boolean] :all merge all available import data
      # @option opts [Array] :only a key/name or list of keys/names to
      #   be merged
      def merge opts={}
        Merger.new(@data_path, opts).merge
      end

      # Get import data from a deck
      # @param [String] name The name of the card to be imported
      # @param [Hash] opts pull options
      # @option opts [String] remote Use a remote url. The remote url must
      #   have been registered via 'add_remote'
      # @option opts [Boolean] deep if true fetch all nested cards, too
      # @option opts [Boolean] items_only if true fetch all nested cards but
      #   not the card itself
      def pull name, opts={}
        update do |import_data|
          url = opts[:remote] ? import_data.url(opts.delete(:remote)) : nil
          fetch_card_data(name, url, opts).each do |card_data|
            import_data.add_card card_data
          end
        end
      end

      # Add a card with the given attributes to the import data
      def add_card attr
        update do |data|
          data.add_card attr
        end
      end

      # Save an url as remote deck to make it available for the pull method
      def add_remote name, url
        update do |data|
          data.add_remote name, url
        end
      end

      private

      def update &block
        ImportData.update(@data_path, &block)
      end

      def importer
        @importer ||= ImportData.new(@data_path)
      end

      # Returns an array of hashes with card attributes
      def fetch_card_data name, url, opts
        view, result_key =
          if opts[:items_only]
            ["export_items", nil]
          elsif opts[:deep]
            ["export", nil]
          else
            [nil, :card]
          end
        card_data =
          if url
            fetch_remote_data name, view, url
          else
            fetch_local_data name, view
          end
        result_key ? [card_data[result_key]] : card_data
      end

      def fetch_remote_data name, view, url
        json_url = "#{url}/#{name}.json"
        json_url += "?view=#{view}" if view
        json = ::File.open(json_url).read
        parse_and_symbolize json
      end

      def fetch_local_data name, view
        Card::Auth.as_bot do
          Card[name].format(format: :json).render!(view || :page)
        end
      end

      def parse_and_symbolize json
        parsed = JSON.parse(json)
        case parsed
        when Hash then
          parsed.deep_symbolize_keys
        when Array then
          parsed.map(&:deep_symbolize_keys)
        else
          parsed
        end
      end
    end
  end
end
