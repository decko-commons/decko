RSpec.shared_context "json context", shared_context: :json do
  before do
    Card::Env[:host] = "json.com"
    Card::Env[:protocol] = "http://"
  end

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
      url: json_url(card.name.url_key),
      html_url: "#{root}/#{card.name.url_key}"
    }
  end

  def atom_values card=card_subject, structured: false
    values = nucleus_values(card).merge(
      type: card.type_name,
      type_url: json_url(card.type_name),
      molecule_url: json_url(card.name.url_key, "view=molecule")
    )
    values[:content] = card.content unless structured
    values
  end

  def structured_atom_values card=card_subject
    atom_values card, structured: true
  end
end
