# -*- encoding : utf-8 -*-

# require "card/env"

require "cardname"

class Card
  # The {Cardname} class provides generalized of Card naming patterns
  # (compound names, key-based variants, etc)
  #
  # {Card::Name} adds support for deeper card integration
  class Name < Cardname
    include NameVariants

    class << self
      def [] *cardish
        cardish = cardish.first if cardish.size <= 1
        case cardish
        when Card             then cardish.name
        when Symbol, Integer  then Card.fetch_name(cardish)
        when Array            then compose cardish
        when String, NilClass then new cardish
        else
          raise ArgumentError, "#{cardish.class} not supported as name identifier"
        end
      end

      def session
        Card::Auth.current.name # also_yuck
      end

      def params
        Card::Env.params
      end

      def new str, validated_parts=nil
        return compose str if str.is_a?(Array)

        str = str.to_s

        if !validated_parts && str.include?(joint)
          string_compose Cardname.split_parts(str)
        elsif (id = Card.id_from_string str)  # handles ~[id] and :[codename]
          Card.name_from_id_from_string id, str
        else
          super str
        end
      end

      # interprets symbols/integers as codenames/ids
      def compose parts
        new_from_parts(parts) { |part| self[part] }
      end

      private

      def string_compose parts
        new_from_parts(parts) { |part| new part }
      end

      def new_from_parts parts, &block
        name_parts = parts.flatten.map(&block)
        new name_parts.join(joint), true
      end
    end

    def star?
      simple? && s[0, 1] == "*"
    end

    def rstar?
      right && right[0, 1] == "*"
    end
  end
end
