
format :jsonld do
  def jsonld_supported? = true

  def resource_iri
    path(mark: card.name, format: nil)
  end
end

def export_formats
  %i[csv json jsonld]
end
