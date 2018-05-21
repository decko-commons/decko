class Card
  # Card::Mark provides class methods for Card to translate all different kind
  # of card identifiers to card objects.
  module Mark
    ID_MARK_RE = /^~(?<id>\d+)$/
    CODENAME_MARK_RE = /^:(?<codename>\w+)$/

    # translates marks (and other inputs) into a Card
    #
    # @param cardish [Card, Card::Name, String, Symbol, Integer]
    # @return Card
    def cardish cardish
      if cardish.is_a? Card
        cardish
      else
        fetch cardish, new: {}
      end
    end

    # translates various inputs into either an id or a name.
    # @param parts [Array<Symbol, Integer, String, Card::Name, Card>] a mark or mark parts
    # @return [Integer or Card::Name]
    def id_or_name parts
      mark = parts.flatten
      mark = mark.first if mark.size <= 1
      id_from_mark(mark) || name_from_mark(mark)
    end

    def id_from_mark mark
      case mark
      when Integer then mark
      when Symbol  then Card::Codename.id! mark
      when String  then id_from_string mark
      end
    end

    # translates string identifiers into an id:
    #   - string id notation (eg "~75")
    #   - string codename notation (eg ":options")
    #
    # @param mark [String]
    # @return [Integer or nil]
    def id_from_string mark
      case mark
      when ID_MARK_RE       then Regexp.last_match[:id].to_i
      when CODENAME_MARK_RE then Card::Codename.id! Regexp.last_match[:codename]
      end
    end

    def bad_mark mark
      case mark
      when ID_MARK_RE
        raise Card::Error::NotFound, "id doesn't exist: #{Regexp.last_match[:id]}"
      when CODENAME_MARK_RE
        raise Card::Error::CodenameNotFound,
              "codename doesn't exist: #{Regexp.last_match[:codename]}"
      else
        raise Card::Error, "invalid mark: #{mark}"
      end
    end

    def name_from_mark mark
      Card::Name[mark]
    end
  end
end
