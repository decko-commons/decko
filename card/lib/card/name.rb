# -*- encoding : utf-8 -*-
require_dependency "card/env"

require "cardname"

class Card
  # The Cardname class provides generalized of Card naming patterns
  # (compound names, key-based variants, etc)
  #
  # Card::Name adds support for deeper card integration
  class Name < Cardname
    include FieldsAndTraits
    include ::Card::Name::NameVariants

    self.params  = Card::Env # yuck!
    self.session = proc { Card::Auth.current.name } # also_yuck

    class << self
      def [] *cardish
        cardish = cardish.first if cardish.size <= 1
        case cardish
        when Card            then cardish.name
        when Symbol, Integer then Card.fetch_name(cardish)
        when Array           then compose cardish
        else                      cardish.to_name
        end
      end

      def compose parts
        new parts.flatten.map { |part| self[part] }.join(joint)
      end

      def url_key_to_standard key
        key.to_s.tr "_", " "
      end
    end

    def star?
      simple? && "*" == s[0, 1]
    end

    def rstar?
      right && "*" == right[0, 1]
    end

    def code
      Card::Codename[Card.fetch_id self]
    end

    def setting?
      Set::Type::Setting.member_names[key]
    end

    def set?
      Set::Pattern.card_keys[tag_name.key]
    end
  end
end
