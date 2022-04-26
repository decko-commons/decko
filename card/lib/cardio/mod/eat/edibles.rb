module Cardio
  class Mod
    class Eat
      # item handling for Mod::Eat (importables)
      module Edibles
        DATA_ENVIRONMENTS = %i[production development test].freeze

        # list of card attribute hashes
        # @return [Array <Hash>]
        def edibles
          mods_with_data.map { |mod| mod_edibles mod }.flatten
        end

        private

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
          environments.map { |env| items_for_environment mod, env }.compact
        end

        def items_for_environment mod, env
          return unless (items = items_from_yaml mod, env)

          items = items.map do |item|
            item.is_a?(String) ? items_from_yaml(mod, env, item) : item
          end.flatten.compact
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

        # for processing that needs to happen on all cards, including fields
        def each_card_hash items
          items.each do |item|
            yield item
            item[:subfields]&.values&.each { |val| yield val if val.is_a? Hash }
          end
          items
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

        # @return [Array <Symbol>]
        # holarchical. each includes the previous
        # production = [:production],
        # development = [:production, :development], etc.
        def environments
          # index = DATA_ENVIRONMENTS.index(@env&.to_sym || Rails.env.to_sym) || -1
          # DATA_ENVIRONMENTS[0..index]

          [@env]
        end
      end
    end
  end
end
