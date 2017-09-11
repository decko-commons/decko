# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::AssignAttributes do
  include CardExpectations


  # FIXME: - following tests more about fetch than set_name.
  # this spec still needs lots of cleanup

  it "test fetch with new when present" do
    Card.create!(name: "Carrots")
    cards_should_be_added 0 do
      c = Card.fetch "Carrots", new: {}
      c.save
      expect(c).to be_instance_of(Card)
      expect(Card.fetch("Carrots")).to be_instance_of(Card)
    end
  end

  it "test_simple" do
    cards_should_be_added 1 do
      expect(Card["Boo!"]).to be_nil
      expect(Card.create(name: "Boo!")).to be_instance_of(Card)
      expect(Card["Boo!"]).to be_instance_of(Card)
    end
  end

  it "test fetch with new when not present" do
    c = Card.fetch("Tomatoes", new: {})
    expect do
      c.save
    end.to increase_card_count_by(1)
    expect(c).to be_instance_of(Card)
    expect(Card.fetch("Tomatoes")).to be_instance_of(Card)
  end

  private

  def cards_should_be_added number
    number += Card.all.count
    yield
    expect(Card.all.count).to eq(number)
  end
end
