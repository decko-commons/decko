# -*- encoding : utf-8 -*-

# require "card/env"

require "cardname"

class Card
  # The {Cardname} class provides generalized of Card naming patterns (compound names,
  # key-based variants, etc) and can be used independently of Card objects.
  #
  # {Card::Name} adds support for deeper integration with Card objects
  class Name < Cardname
    include NameVariants

    class << self
      # @return [Card::Name]
      def [] *cardish
        cardish = cardish.first if cardish.size <= 1
        from_cardish(cardish) || unsupported_class!(cardish)
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
          new_from_compound_string str
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

      def from_cardish cardish
        case cardish
        when Card             then cardish.name
        when Integer          then Lexicon.name cardish
        when Symbol           then Codename.name! cardish
        when Array            then compose cardish
        when String, NilClass then new cardish
        end
      end

      def unsupported_class! cardish
        raise ArgumentError, "#{cardish.class} not supported as name identifier"
      end

      def new_from_compound_string string
        parts = Cardname.split_parts string
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
