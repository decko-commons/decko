class Card
  module Model
    module SaveHelper
      # private helper methods for public SaveHelper api
      module SaveHelperHelper
        CARDTYPE_METHOD_REGEXP = /^(?<method_name>create|ensure)_(?<type>.+?)(?:_card)?$/

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

          Card.ensure name: name, type_id: type_id, codename: codename
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
          return unless (match = method.match CARDTYPE_METHOD_REGEXP)

          cardtype_card = cardtype_card_from_string match[:type]

          return unless cardtype_card&.type_id == CardtypeID || cardtype_card&.id == SetID

          [match[:method_name], cardtype_card]
        end

        def cardtype_card_from_string type
          Card::Codename[type.to_sym] ? Card[type.to_sym] : Card[type]
        end

        def ensure_card_simplified name, args
          Card.ensure_update(name, args) || Card.create!(add_name(name, args))
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
          return if Codename.exist?(setting) && Card.fetch_type_id(setting) == SettingID

          raise ArgumentError, "not a valid setting: #{setting}"
        end

        def normalize_trait_rule_args setting, value
          return value if value.is_a? Hash

          if Card.fetch_type_id([setting, :right, :default]) == PointerID
            value = Array(value).to_pointer_content
          end
          { content: value }
        end

        def add_name name, content_or_args
          if content_or_args.is_a?(Hash)
            content_or_args.reverse_merge name: name
          else
            { content: content_or_args, name: name }
          end
        end
      end
    end
  end
end
