module CoreExtensions
  # extensions to Symbol class
  module Symbol
    include PersistentIdentifier

    # interpret symbol as codename
    def cardname
      Card::Codename.name self
    end
  end
end
