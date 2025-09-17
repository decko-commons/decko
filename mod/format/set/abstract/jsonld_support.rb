module Card::Set::Abstract::JsonldSupport
  extend Card::Set

  format :jsonld do
    def jsonld_supported_collection? = true
  end
end