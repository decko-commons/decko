module Cardio
  class Mod
    class Eat
      # item handling for Mod::Eat (importables)
      module Edibles
        # list of card attribute hashes
        # @return [Array <Hash>]
        def edibles
          explicit_edibles { mods_with_data.map { |mod| mod_edibles mod }.flatten }
        end

        private

        def explicit_edibles
          return yield unless @name

          yield.reject do |edible|
            if @name.match?(/^\:/)
              explicit_codename_match? edible[:codename]
            else
              explicit_name_match? edible[:name]
            end
          end
        end

        def explicit_codename_match? codename
          codename && (codename == @name[1..-1])
        end

        def explicit_name_match? name
          name && (name.to_name == @name.to_name)
        end

        # if mod is specified, consider only that mod
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

        # @return [Array <Hash>]
        def mod_edibles mod
          pod_types.map { |type| items_for_type mod, type }.compact
        end

        def items_for_type mod, type
          return unless (items = items_from_yaml mod, type)

          items = items.map do |item|
            item.is_a?(String) ? items_from_yaml(mod, type, item) : item
          end.flatten.compact
          interpret_items mod, items
        end

        def interpret_items mod, items
          each_card_hash(items) { |hash| handle_attachments mod, hash }
        end

        def items_from_yaml mod, type, filename=nil
          source = "#{type}#{'/' if filename.present?}#{filename}.yml"
          return unless (path = mod.subpath "data", source)

          YAML.load_file path
        end

        # for processing that needs to happen on all cards, including fields
        def each_card_hash items, &block
          items.each do |item|
            raise Card::Error, "inedible pod data: #{item}" unless item.is_a? Hash

            yield item
            process_fields item, &block
          end
          items
        end

        def process_fields item
          item[:fields]&.values&.each { |val| yield val if val.is_a? Hash }
        end

        def handle_attachments mod, hash
          each_attachment hash do |key, filename|
            hash[key] = mod_file mod, filename
            hash[:mod] = mod.name if hash[:storage_type] == :coded
          end
        end

        def each_attachment hash
          attachment_keys.each { |key| yield key, hash[key] if hash.key? key }
        end

        def mod_file mod, filename
          unless (mod_file_path = mod.subpath "data/files", filename)
            raise StandardError, "#{filename} not found. "\
                                 "Should be in data/files in #{mod.name} mod."
          end
          File.open mod_file_path
        end

        def attachment_keys
          @attachment_keys ||= Card.uploaders.keys
        end

        def pod_types
          if @pod_type == :all
            %i[real test]
          elsif @pod_type
            [@pod_type]
          elsif Rails.env.test?
            %i[real test]
          else
            [:real]
          end
        end
      end
    end
  end
end
