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
      def cardish mark
        case mark
        when Card            then mark.name
        when Symbol, Integer then Card.quick_fetch(mark).name
        else                      mark.to_name
        end
      end

      def compose parts
        parts.flatten.map { |part| cardish part }.join joint
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
