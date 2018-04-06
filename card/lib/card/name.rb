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
        when Card             then cardish.name
        when Symbol, Integer  then Card.fetch_name(cardish)
        when Array            then smart_compose cardish
        when String, NilClass then new cardish
        else
          raise ArgumentError, "#{cardish.class} not supported as name identifier"
        end
      end

      def new str, validated_parts=nil
        return compose str if str.is_a?(Array)

        str = str.to_s

        if !validated_parts && str.include?(joint)
          compose Cardname.split_parts(str)
        elsif (id = Card.id_from_string(str))  # handles ~ and :
          Card.fetch_name(id) { Card.bad_mark(str) }
        else
          super str
        end
      end

      # interprets symbols/integers as codenames/ids
      def smart_compose parts
        name_parts = parts.flatten.map { |part| self[part] }
        new name_parts.join(joint), true
      end

      def compose parts
        name_parts = parts.flatten.map { |part| new part }
        new name_parts.join(joint), true
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
