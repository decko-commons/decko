# -*- encoding : utf-8 -*-

def it_generates opts
  name = opts[:name]
  card = opts[:from]
  it "generates name '#{name}' for card '#{card.name}'" do
    expect(described_class.new(card).to_s).to eq(name)
  end
end

RSpec.describe Card::Set::Pattern do
  specify "#grouped_codes" do
    expect(described_class.grouped_codes).to eq(
      [[:all], [:abstract], %i[all_plus type star rstar rule right type_plus_right self]]
    )
  end
end

# FIXME: - these should probably be in pattern-specific specs,
# though that may not leave much to test in the base class :)

RSpec.describe Card::Set::Right do
  it_generates name: "author+*right", from: Card.new(name: "Iliad+author")
  it_generates name: "author+*right", from: Card.new(name: "+author")
end

RSpec.describe Card::Set::Type do
  it_generates name: "Book+*type", from: Card.new(type: "Book")
end

RSpec.describe Card::Set::AllPlus do
  it_generates name: "*all plus", from: Card.new(name: "Book+author")
end

RSpec.describe Card::Set::All do
  it_generates name: "*all", from: Card.new(type: "Book")
end

RSpec.describe Card::Set::TypePlusRight do
  author_card = Card.new(name: "Iliad+author")
  it_generates name: "Book+author+*type plus right", from: author_card
end
