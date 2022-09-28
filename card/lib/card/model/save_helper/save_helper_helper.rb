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
