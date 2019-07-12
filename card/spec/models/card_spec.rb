# -*- encoding : utf-8 -*-

RSpec.describe Card do
  describe "test data" do
    it "is findable by name" do
      expect(Card["Decko Bot"]).to be_a Card
    end
  end

  describe "creation" do
    before(:each) do
      Card::Auth.as_bot do
        @b = Card.create! name: "New Card", content: "Great Content"
        @c = Card.find(@b.id)
      end
    end

    it "does not have errors"  do expect(@b.errors.size).to eq(0)        end
    it "has the right class"   do expect(@c.class).to    eq(Card)        end
    it "has the right key"     do expect(@c.key).to      eq("new_card")  end
    it "has the right name"    do expect(@c.name).to     eq("New Card")  end
    it "has the right content" do expect(@c.content).to  eq("Great Content") end

    it "has the right content" do
      expect(@c.db_content).to eq("Great Content")
      expect(@c.content).to eq("Great Content")
    end

    it "is findable by name" do
      expect(Card["New Card"].class).to eq(Card)
    end
  end

  describe "content change should create new action" do
    before do
      Card::Auth.as_bot do
        @c = Card["basicname"]
        @c.update! content: "foo"
      end
    end

    it "has 2 actions"  do
      expect(@c.actions.count).to eq(2)
    end

    it "has original action" do
      expect(@c.nth_action(1).value :db_content).to eq("basiccontent")
    end
  end

  example "creates a virtual card when missing" do
    expect(Card.new(name: "A+*last edited")).to be_virtual
  end
end

describe "basic card tests" do
  def assert_simple_card card
    expect(card.name).to be, "name not null"
    expect(card.name.empty?).to be_falsey, "name not empty"
    action = card.last_action
    expect(action).to be_instance_of Card::Action
    expect(action.act.actor).to be_instance_of Card
  end

  def assert_samecard card1, card2
    assert_equal card1, card2
  end

  def assert_stable card1
    card2 = Card[card1.name]
    assert_simple_card card1
    assert_simple_card card2
    assert_samecard card1, card2
    assert_equal card1.right, card2.right
  end

  it "creates cards" do
    alpha = Card.new name: "alpha", content: "alpha"
    expect(alpha.content).to eq("alpha")
    alpha.save
    expect(alpha.name).to eq("alpha")
    assert_stable alpha
  end

  it "does not find nonexistent" do
    expect(Card["no such card+no such tag"]).to be_nil
    expect(Card["HomeCard+no such tag"]).to be_nil
  end

  it "update_should_create_subcards" do
    Card.create! name: "Banana"
    Card["banana"].update! subcards: { "+peel" => { content: "yellow" } }

    peel = Card["Banana+peel"]
    expect(peel.content).       to eq("yellow")
    expect(Card["joe_user"].id).to eq(peel.creator_id)
  end

  it "update_should_create_subcards_as_decko_bot_if_missing_subcard_permissions" do
    Card.create name: "peel"
    Card::Auth.current_id = Card::AnonymousID
    expect(Card["Banana"]).not_to be
    expect(Card[:basic].ok?(:create)).to be_falsey, "anon can't creat"

    Card.create! type: "Fruit", name: "Banana", subcards: { "+peel" => { content: "yellow" } }
    expect(Card["Banana"]).to be
    peel = Card["Banana+peel"]

    expect(peel.db_content).to eq("yellow")
    expect(peel.creator_id).to eq(Card::AnonymousID)
  end

  context "missing main card permissions" do
    it "update doesn't create subcards" do
      b = create! "Banana"
      Card::Auth.as Card::AnonymousID do
        b.update subcards: { "+peel" => { content: "yellow" } }
        expect(b.errors[:permission_denied]).not_to be_empty

        c = Card.update(b.id, subcards: { "+peel" => { content: "yellow" } })
        expect(c.errors[:permission_denied]).not_to be_empty
        expect(Card["Banana+peel"]).to be_nil
      end
    end
  end

  it "create_without_read_permission" do
    c = Card.create!(name: "Banana", type: "Fruit", content: "mush")
    Card::Auth.as Card::AnonymousID do
      assert_raises Card::Error::PermissionDenied do
        c.ok! :read
      end
    end
  end
end
