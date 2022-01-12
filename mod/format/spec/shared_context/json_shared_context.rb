RSpec.shared_context "json context", shared_context: :json do
  before { Card.config.deck_origin = "http://json.com" }
  after { Card.config.deck_origin = nil }

  let(:root) { "http://json.com" }

  def json_url target, query=nil
    url "#{target}.json", query
  end

  def url target, query=nil
    ["#{root}/#{target}", query].compact.join "?"
  end

  def nucleus_values card=card_subject
    {
      id: card.id,
      name: card.name,
      type: card.type_name,
      url: json_url(card.name.url_key)
    }
  end

  def atom_values card=card_subject, structured: false
    values = nucleus_values card
    values[:content] = card.content unless structured
    values
  end

  def structured_atom_values card=card_subject
    atom_values card, structured: true
  end
end
