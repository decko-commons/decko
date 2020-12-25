class Card
  module Model
    module SaveHelper
      # private helper methods for public SaveHelper api
      module SaveHelperHelper
        private

        def codename_from_name name
          name.downcase.tr(" ", "_").tr(":*", "")
        end

        def delete_code_card? name
          return false if name.is_a?(Symbol) && !Codename.exist?(name)

          Card.exist? name
        end

        def add_coderule_item name, prefix, type_id, to
          codename = "#{prefix}_#{name.tr(' ', '_').underscore}"
          name = "#{prefix}: #{name}"

          ensure_card name, type_id: type_id,
                      codename: codename
          Card[to].add_item! name
        end

        def method_missing method, *args
          method_name, cardtype_card = extract_cardtype_from_method_name method
          return super unless method_name

          sargs = standardize_args(*args)
          send "#{method_name}_card", sargs.merge(type_id: cardtype_card.id)
        end

        def respond_to_missing? method, _include_private=false
          extract_cardtype_from_method_name(method) || super
        end

        def extract_cardtype_from_method_name method
          return unless method =~ /^(?<method_name>create|ensure)_(?<type>.+?)(?:_card)?$/

          type = Regexp.last_match[:type]
          cardtype_card = Card::Codename[type.to_sym] ? Card[type.to_sym] : Card[type]
          return unless cardtype_card&.type_id == Card::CardtypeID ||
              cardtype_card&.id == Card::SetID

          [Regexp.last_match[:method_name], cardtype_card]
        end

        def ensure_card_simplified name, args
          ensure_card_update(name, args) || Card.create!(add_name(name, args))
        end

        def ensure_card_update name, args
          card = Card[name]
          return unless card

          ensure_attributes card, args
          card
        rescue Card::Error::CodenameNotFound => _e
          false
        end

        def validate_setting setting
          unless Card::Codename.exist?(setting) &&
              Card.fetch_type_id(setting) == Card::SettingID
            raise ArgumentError, "not a valid setting: #{setting}"
          end
        end

        def normalize_trait_rule_args setting, value
          return value if value.is_a? Hash

          if Card.fetch_type_id([setting, :right, :default]) == Card::PointerID
            value = Array(value).to_pointer_content
          end
          { content: value }
        end

        # @return args
        def standardize_args name_or_args, content_or_args=nil, _ignore=nil
          if name_or_args.is_a?(Hash)
            name_or_args
          else
            add_name name_or_args, content_or_args || {}
          end
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

        def create_args name_or_args, content_or_args=nil
          args = standardize_args name_or_args, content_or_args
          resolve_name_conflict args
          args
        end

        def name_from_args name_or_args
          name_or_args.is_a?(Hash) ? name_or_args[:name] : name_or_args
        end

        def add_name name, content_or_args
          if content_or_args.is_a?(Hash)
            content_or_args.reverse_merge name: name
          else
            { content: content_or_args, name: name }
          end
        end

        def resolve_name_conflict args
          rename = args.delete :rename_if_conflict
          return unless args[:name] && rename

          args[:name] = Card.uniquify_name args[:name], rename
        end

        def ensure_attributes card, args
          subcards = card.extract_subcard_args! args
          update_args = changing_args card, args

          return if update_args.empty? && subcards.empty?

          # FIXME: use ensure_attributes for subcards
          card.update! update_args.merge(subcards: subcards, skip: :validate_renaming)
        end

        def changing_args card, args
          args.select do |key, value|
            case key.to_s
            when /^\+/
              subfields[key] = value
              false
            when "name"
              card.name.to_s != value
            else
              card.send(key) != value unless value.is_a? ::File
            end
          end
        end
      end
    end
  end
end