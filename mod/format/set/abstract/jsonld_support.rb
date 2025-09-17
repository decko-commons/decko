format :jsonld do
  def jsonld_supported? = true
end

def export_formats
  %i[csv json jsonld]
end