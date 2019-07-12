# -*- encoding : utf-8 -*-

describe Card, "created by Card.new" do
  before(:each) do
    Card::Auth.as_bot do
      @c = Card.new name: "New Card", content: "Great Content"
    end
  end

  it "does not create a new card until saved" do
    expect do
      Card.new(name: "foo", type: "Cardtype")
    end.not_to increase_card_count
  end

  it "does not override explicit content with default content", as_bot: true do
    create "blue+*right+*default", content: "joe", type: "Pointer"
    c = Card.new name: "Lady+blue", content: "[[Jimmy]]"
    expect(c.content).to eq("[[Jimmy]]")
  end
end

describe Card, "created by Card.create with valid attributes" do
  before(:each) do
    Card::Auth.as_bot do
      @b = Card.create name: "New Card", content: "Great Content"
      @c = Card.find(@b.id)
    end
  end

  it "does not have errors" do
    expect(@b.errors.size).to eq(0)
  end
  it "has the right class" do
    expect(@c.class).to eq(Card)
  end
  it "has the right key" do
    expect(@c.key).to eq("new_card")
  end
  it "has the right name" do
    expect(@c.name).to eq("New Card")
  end
  it "has the right content" do
    expect(@c.content).to eq("Great Content")
  end

  it "has the right content" do
    expect(@c.db_content).to eq "Great Content"
  end

  it "is findable by name" do
    expect(Card["New Card"]).to be_a Card
  end
end

describe Card, "create junction two parts" do
  before(:each) do
    @c = Card.create! name: "Peach+Pear", content: "juicy"
  end

  it "doesn't have errors" do
    expect(@c.errors.size).to eq(0)
  end

  it "creates junction card" do
    expect(Card["Peach+Pear"]).to be_a(Card)
  end

  it "creates trunk card" do
    expect(Card["Peach"]).to be_a(Card)
  end

  it "creates tag card" do
    expect(Card["Pear"]).to be_a(Card)
  end
end

describe Card, "create junction three parts" do
  it "creates very left card" do
    Card.create! name: "Apple+Peach+Pear", content: "juicy"
    expect(Card["Apple"].class).to eq(Card)
  end

  it "sets left and right ids" do
    Card.create! name: "Sugar+Milk+Flour", content: "tasty"
    sugar_milk = Card["Sugar+Milk"]
    sugar_milk_flour = Card["Sugar+Milk+Flour"]
    expect(sugar_milk_flour.left_id).to eq(sugar_milk.id)
    expect(sugar_milk_flour.right_id).to eq(Card.fetch_id("Flour"))
    expect(sugar_milk.left_id).to eq(Card.fetch_id("Sugar"))
    expect(sugar_milk.right_id).to eq(Card.fetch_id("Milk"))
  end
end


describe Card, "Joe User" do
  before do
    Card::Auth.as_bot do
      @r3 = Card["r3"]
      Card.create name: "Cardtype F+*type+*create", type: "Pointer", content: "[[r3]]"
    end

    @ucard = Card::Auth.current
    @type_names = Card::Auth.createable_types
  end

  it "does not have r3 permissions" do
    expect(@ucard.fetch(new: {}, trait: :roles).item_names.member?(@r3.name)).to be_falsey
  end
  it "ponders creating a card of Cardtype F, but find that he lacks create permissions" do
    expect(Card.new(type: "Cardtype F").ok?(:create)).to be_falsey
  end
  it "does not find Cardtype F on its list of createable cardtypes" do
    expect(@type_names.member?("Cardtype F")).to be_falsey
  end
  it "finds Basic on its list of createable cardtypes" do
    expect(@type_names.member?("RichText")).to be_truthy
  end
end
