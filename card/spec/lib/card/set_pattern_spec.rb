# -*- encoding : utf-8 -*-

def it_generates opts
  name = opts[:name]
  card = opts[:from]
  it "generates name '#{name}' for card '#{card.name}'" do
    expect(described_class.new(card).to_s).to eq(name)
  end
end

RSpec.describe Card::Set::Pattern do
  specify ".in_load_order" do
    expect(Card::Set::Pattern.in_load_order)
      .to eq(%i[abstract all all_plus type star rstar rule right type_plus_right self])
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

  before :each do
    Card::Auth.as_bot do
      @mylist = Card.create! name: "MyList", type_id: Card::CardtypeID
      Card.create name: "MyList+*type+*default", type_id: Card::PointerID
    end
    @mylist_card = Card.create name: "ip", type_id: @mylist.id
  end

  # similar tests for an inherited type of Pointer
it "has inherited set module" do
    expect(@mylist_card.set_modules).to include(Card::Set::Type::Pointer)
    expect(@mylist_card.set_format_modules(Card::Format::HtmlFormat))
      .to include(Card::Set::Type::Pointer::HtmlFormat)
    expect(@mylist_card.set_format_modules(Card::Format::CssFormat))
      .to include(Card::Set::Type::Pointer::CssFormat)
    expect(@mylist_card.set_format_modules(Card::Format::JsFormat))
      .to include(Card::Set::Type::Pointer::JsFormat)

  end
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
