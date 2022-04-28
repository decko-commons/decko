class Card
  module Model
    module SaveHelper
      # private helper methods for public SaveHelper api
      module SaveArguments
        private

        # @return args
        def standardize_args name_or_args, content_or_args=nil, _ignore=nil
          if name_or_args.is_a?(Hash)
            name_or_args
          else
            add_name name_or_args, content_or_args || {}
          end
        end

        def standardize_ensure_args name_or_args, content_or_args
          name = name_or_args.is_a?(Hash) ? name_or_args[:name] : name_or_args
          args = if name_or_args.is_a?(Hash)
                   name_or_args
                 else
                   hashify content_or_args, :content
                 end
          [name, args]
        end

        def standardize_update_args name_or_args, content_or_args
          return name_or_args if name_or_args.is_a?(Hash)

          hashify content_or_args, :content
        end

        def hashify value_or_hash, key
          if value_or_hash.is_a?(Hash)
            value_or_hash
          elsif value_or_hash.nil?
            {}
          else
            { key => value_or_hash }
          end
        end

        def create_args name_or_args, content_or_args=nil
          args = standardize_args name_or_args, content_or_args
          resolve_name_conflict args
          args
        end

        def name_from_args name_or_args
          name_or_args.is_a?(Hash) ? name_or_args[:name] : name_or_args
        end

        def resolve_name_conflict args
          rename = args.delete :rename_if_conflict
          return unless args[:name] && rename

          args[:name] = Card.uniquify_name args[:name], rename
        end

        def ensure_attributes card, args
          subcards = card.extract_subcard_args! args.symbolize_keys!
          update_args = changing_args card, args

          return if update_args.empty? && subcards.empty?

          puts "not empty: #{update_args} ;;; #{subcards}"

          update_args[:skip] =
            [update_args[:skip], :validate_renaming].flatten.compact.map(&:to_sym)

          # FIXME: use ensure_attributes for subcards
          card.update! update_args.merge(subcards: subcards)
        end

        def changing_args card, args
          args.select do |key, value|
            case key.to_s
            when "storage_type"
              true # because we have to re-assert coded, otherwise it changes
            when "type"
              changing_type_val? card, value
            when /^\+/
              changing_field_arg key, value
            when "name", "codename"
              changing_name_val? card, key, value
            else
              standard_changing_arg card, key, value
            end
          end
        end

        def changing_name_val? card, key, value
          card.send(key).to_s != value.to_name.to_s
        end

        def changing_type_val? card, value
          if value.is_a? Symbol
            card.type_code != value
          else
            card.type_name != value.to_name
          end
        end

        def changing_field_arg key, value
          subfields[key] = value
          false
        end

        def standard_changing_arg card, key, value
          return true if value.is_a? ::File

          card.send(key) != value
        end
      end
    end
  end
end
