class Card
  # Card::Mark provides class methods for Card to translate all different kind
  # of card identifiers to card objects.
  module Mark
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
      id_from_mark(mark) || Card::Name[mark]
    end

    private

    def id_from_mark mark
      case mark
      when Integer then mark
      when Symbol  then Codename.id! mark
      when String  then Name.id_from_string! mark
      when Card    then mark.id
      end
    end
  end
end
