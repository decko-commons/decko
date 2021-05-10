# -*- encoding : utf-8 -*-

RSpec.describe Card do
  context "when created by Card.new" do
    it "does not create a new card until saved" do
      expect { described_class.new(name: "foo", type: "Cardtype") }
        .not_to increase_card_count
    end

    it "does not override explicit content with default content", as_bot: true do
      create "blue+*right+*default", content: "joe", type: "Pointer"
      c = described_class.new name: "Lady+blue", content: "[[Jimmy]]"
      expect(c.content).to eq("[[Jimmy]]")
    end
  end

  context "when created by Card.create with valid attributes" do
    let(:b) { described_class.create name: "New Card", content: "Great Content" }
    let(:c) { described_class.find(b.id) }

    it "does not have errors" do
      expect(b.errors.size).to eq(0)
    end

    it "has the right class" do
      expect(c.class).to eq(described_class)
    end

    it "has the right key" do
      expect(c.key).to eq("new_card")
    end

    it "has the right name" do
      expect(c.name).to eq("New Card")
    end

    it "has the right content" do
      expect(c.content).to eq("Great Content")
    end

    it "has the right content" do
      expect(c.db_content).to eq "Great Content"
    end

    it "is findable by name" do
      c
      expect(described_class["New Card"]).to be_a described_class
    end
  end

  context "when creating two-part junction" do
    before { c }
    let(:c) {  described_class.create! name: "Peach+Pear", content: "juicy" }

    it "doesn't have errors" do
      expect(c.errors.size).to eq(0)
    end

    it "creates junction card" do
      expect(described_class["Peach+Pear"]).to be_a(described_class)
    end

    it "creates trunk card" do
      expect(described_class["Peach"]).to be_a(described_class)
    end

    it "creates tag card" do
      expect(described_class["Pear"]).to be_a(described_class)
    end
  end

  context "when creating three-part junction" do
    it "creates very left card" do
      described_class.create! name: "Apple+Peach+Pear", content: "juicy"
      expect(described_class["Apple"].class).to eq(described_class)
    end

    it "sets left and right ids" do
      described_class.create! name: "Sugar+Milk+Flour", content: "tasty"
      sugar_milk = described_class["Sugar+Milk"]
      sugar_milk_flour = described_class["Sugar+Milk+Flour"]
      expect(sugar_milk_flour.left_id).to eq(sugar_milk.id)
      expect(sugar_milk_flour.right_id).to eq("Flour".card_id)
      expect(sugar_milk.left_id).to eq("Sugar".card_id)
      expect(sugar_milk.right_id).to eq("Milk".card_id)
    end
  end

  context "when created by Joe User" do
    before do
      Card::Auth.as_bot do
        described_class.create name: "Cardtype F+*type+*create", type: "Pointer",
                               content: "[[r3]]"
      end
    end

    let(:r3) { described_class["r3"] }
    let(:ucard) { Card::Auth.current }
    let(:type_names) { Card::Auth.createable_types }

    it "does not have r3 permissions" do
      expect(ucard.fetch(:roles, new: {}).item_names).not_to be_member(r3.name)
    end

    it "ponders creating a card of Cardtype F, but find that he lacks create permissions" do
      expect(described_class.new(type: "Cardtype F")).not_to be_ok(:create)
    end

    it "does not find Cardtype F on its list of createable cardtypes" do
      expect(type_names).not_to be_member("Cardtype F")
    end

    it "finds Basic on its list of createable cardtypes" do
      expect(type_names).to be_member("RichText")
    end
  end
end
