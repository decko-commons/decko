module CoreExtensions
  # methods for codenames and numerical ids
  # included in Integer and Symbol
  module PersistentIdentifier
    # interpret symbol/integer as codename/id
    def card
      Card[self]
    end

    # don't interpret symbol/integer as codename/id
    def to_name
      Card::Name.new to_s
    end
  end
end
