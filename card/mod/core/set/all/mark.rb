
module ClassMethods
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

  # @param mark [Symbol, Integer, Card, String, or Card::Name]
  # @return [Integer or Card::Name]
  def id_or_name mark
    case mark
    when Symbol            then id_from_codename! mark
    when Integer           then mark
    when Card              then mark.cardname
    when nil               then "".to_name
    when String, Cardname  then id_or_name_from_string mark.to_s
    # there are some situations where this breaks if we use Card::Name
    # rather than Cardname, which would seem more correct.
    # very hard to reproduce, not captured in a spec :(
    end
  end

  def id_or_name_from_string mark
    case mark
    when /^\~(\d+)$/  # id, eg "~75"
      Regexp.last_match[1].to_i
    when /^\:(\w+)$/  # codename, eg ":options"
      id_from_codename!Regexp.last_match[1].to_sym
    else
      mark.to_name
    end
  end

  def compose_mark parts
    parts.flatten!
    parts.map do |part|
      normpart = id_or_name part
      #normpart = fetch_name(normpart) if parts.size > 1
      normpart
    end.join("+").to_name
  end

  def id_from_codename! mark
    id = Card::Codename[mark]
    raise Card::Error::NotFound, "missing card with codename: #{mark}" unless id
    id
  end
end
