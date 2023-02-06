class Card
  module Set
    # Base class for type sets defined in {Card::Set set modules}
    class Type < Pattern::Base
      cattr_accessor :assignment
      self.assignment = {}
    end
  end
end
