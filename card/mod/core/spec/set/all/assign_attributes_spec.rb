# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::AssignAttributes do
  it "assigns attributes" do
    card = Card.new name: "#name", type: :basic, content: "#content", codename: "#codename"
    expect(card.attributes).to include(
      "name" => "#name",
      "db_content" => "#content",
      "codename" => "#codename",
      "type_id" => Card::BasicID
    )
  end

  it "assigns subcards" do
    card = Card.new name: "#name", subcards: { "sub" => { content: "subcontent" } }
    expect(card.subcards.first).to eq "sub"
    subcard = card.subcard "sub"
    expect(subcard).to be_a(Card)
    expect(subcard.content).to eq "subcontent"
  end

  it "assigns subfields" do
      card = Card.new name: "#name", subfields: { default: { content: "subcontent" } }
      expect(card.subcards.first).to eq "name+*default"
      subcard = card.subfield :default
      expect(subcard).to be_a(Card)
      expect(subcard.name).to eq "#name+*default"
      expect(subcard.content).to eq "subcontent"
    end

  describe "set specific attributes" do
    example "file card with set specfic attribute" do
      card = Card.new name: "empty", type: :file, empty_ok: true
      expect(card.empty_ok?).to be_truthy
    end
  end
end
