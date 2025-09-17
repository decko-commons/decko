format :jsonld do
  def jsonld_supported_collection? = true
end

def export_formats
  %i[csv json jsonld]
end