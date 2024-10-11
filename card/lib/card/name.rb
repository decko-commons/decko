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
      ID_MARK_RE = /^~(?<id>\d+)$/.freeze
      CODENAME_MARK_RE = /^:(?<codename>\w+)$/.freeze

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
        elsif (id = id_from_string str)  # handles ~[id] and :[codename]
          from_id_from_string id, str
        else
          super str
        end
      end

      # interprets symbols/integers as codenames/ids
      def compose parts
        new_from_parts(parts) { |part| self[part] }
      end

      # translates string identifiers into an id:
      #   - string id notation (eg "~75")
      #   - string codename notation (eg ":options")
      #
      # @param string [String]
      # @return [Integer or nil]
      def id_from_string string
        case string
        when ID_MARK_RE       then Regexp.last_match[:id].to_i
        when CODENAME_MARK_RE then Card::Codename.id! Regexp.last_match[:codename]
        end
      end

      def id_from_string! string
        return unless (id = id_from_string string)

        Lexicon.name(id) ? id : bad_mark(string)
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

      def from_id_from_string id, str
        name = Lexicon.name id
        name.present? ? name : bad_mark(str)
      end

      def bad_mark string
        case string
        when ID_MARK_RE
          raise Card::Error::NotFound, "id doesn't exist: #{Regexp.last_match[:id]}"
        when CODENAME_MARK_RE
          raise Card::Error::CodenameNotFound,
                "codename doesn't exist: #{Regexp.last_match[:codename]}"
        else
          raise Card::Error, "invalid mark: #{string}"
        end
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
