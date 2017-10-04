module CoreExtensions
  # methods for codenames and numerical ids
  module PersistentIdentifier
    def card
      Card[self]
    end

    def name
      Card.quick_fetch(self).name
    end
  end
end
