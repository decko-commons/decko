
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

  # translates various inputs into either an id or a name.
  #
  # @param mark [Symbol, Integer, Card, String, or Card::Name]
  # @return [Integer or Card::Name]
  def id_or_name mark
    case mark
    when Symbol            then id_from_codename! mark
    when Integer           then mark
    when Card              then mark.name
    when nil               then "".to_name
    when String, Cardname  then id_or_name_from_string mark.to_s
    # there are some situations where this breaks if we use Card::Name
    # rather than Cardname, which would seem more correct.
    # very hard to reproduce, not captured in a spec :(
    end
  end

  # translates string identifiers into an id or name, including:
  #   - string id notation (eg "~75")
  #   - string codename notation (eg ":options")
  #
  # @param mark [String]
  # @return [Integer or Card::Name]
  def id_or_name_from_string mark
    case mark
    when /^\~(\d+)$/  then  Regexp.last_match[1].to_i
    when /^\:(\w+)$/  then  id_from_codename!Regexp.last_match[1].to_sym
    else                    mark.to_name
    end
  end

  # @param parts [Array] of mark or mark parts
  # @return [Integer or Card::Name]
  def compose_mark parts
    parts.flatten!
    return id_or_name(parts.first) if parts.size == 1
    parts.map do |part|
      Card::Name.cardish id_or_name(part)
    end.join("+").to_name
  end

  # @param codename [Symbol]
  # @return [Integer]
  def id_from_codename! codename
    Card::Codename[codename] || missing_codename!(codename)
  end

  def missing_codename! mark
    raise Card::Error::NotFound, "missing card with codename: #{mark}"
  rescue
    binding.pry
  end

end
