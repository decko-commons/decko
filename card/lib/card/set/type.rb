class Card
  module Set
    class Type < Pattern::Base
      cattr_accessor :assignment
      self.assignment = {}
    end
  end
end
