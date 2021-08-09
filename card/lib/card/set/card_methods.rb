class Card
  module Set
    # Set-related methods included in card class
    # (note: Card::Set::All would follow our naming convention but is in use by the
    # "all" set)
    module CardMethods
      include Event::All
      include Pattern::All

      delegate :basket, to: Set
    end
  end
end
