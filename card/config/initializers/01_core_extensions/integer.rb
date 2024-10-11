require_relative "persistent_identifier"

module CoreExtensions
  # extensions to Integer class
  module Integer
    include PersistentIdentifier

    # interpret integer as id
    def cardname
      Card::Lexicon.name self
    end
  end
end
