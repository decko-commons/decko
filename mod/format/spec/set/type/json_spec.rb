# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Json do
  it "creates card with valid json" do
    json = '{"a":"5"}'
    card = create "a json card", type_id: Card::JsonID, content: json
    expect(card.content).to eq json
  end

  it "rejects invalid json" do
    invalid_json = "{\"a\":\"5\"\n\"b\":\"4\"}"
    expect { create "json card", type: :json, content: invalid_json }
      .to raise_error(/Invalid json.*expected/)
  end
end
