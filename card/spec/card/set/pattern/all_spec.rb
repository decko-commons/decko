# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Pattern::All do
  describe "#set_names" do
    let(:simple_card) { Card.new(name: "AnewCard") }

    it "returns type and all for new simple cards" do
      expect(simple_card.set_names).to eq(["RichText+*type", "*all"])
    end

    it "returns self, type, and all for new simple cards" do
      simple_card.save!
      expect(simple_card.set_names).to eq(["AnewCard+*self", "RichText+*type", "*all"])
    end

    it "returns set names for simple star cards" do
      Card::Auth.as_bot do
        expect(Card.fetch("*update").set_names)
          .to eq(["*update+*self", "*star", "Setting+*type", "*all"])
      end
    end

    it "returns set names for junction cards" do
      Card::Auth.as_bot do
        expect(Card.new(name: "Iliad+author").set_names)
          .to eq(["Book+author+*type plus right",
                  "author+*right",
                  "RichText+*type",
                  "*all plus",
                  "*all"])
      end
    end

    it "returns set names for compound star cards", as_bot: true do
      expect(Card.new(name: "Iliad+*to").set_names)
        .to eq(["Book+*to+*type plus right",
                "*to+*right",
                "*rstar",
                "List+*type",
                "*all plus",
                "*all"])
    end

    it "returns set names for rule cards", as_bot: true do
      expect(Card.new(name: "*all+*create").set_names)
        .to eq(["Set+*create+*type plus right",
                "*create+*right",
                "*rule",
                "*rstar",
                "List+*type",
                "*all plus",
                "*all"])
    end

    # right place for this?  really need more prototype tests...
    it "handles type plus right prototypes properly" do
      Card::Auth.as_bot do
        sets = Card.fetch("Fruit+flavor+*type plus right").prototype.set_names
        expect(sets).to include("Fruit+flavor+*type plus right")
      end
    end
  end

  describe "#rule_lookup_keys" do
    it "returns correct set names for new cards" do
      card = Card.new name: "AnewCard"
      expect(card.rule_lookup_keys).to eq(["#{Card::BasicID}+type", "all"])
    end
  end

  describe "#safe_set_keys" do
    context "with simple star cards" do
      let(:star_card) { Card.new(name: "*AnewCard") }
      let(:all_type_star) { "ALL TYPE-rich_text STAR" }

      it "includes STAR class" do
        expect(star_card.safe_set_keys).to eq(all_type_star)
      end

      it "includes SELF class when real", as_bot: true do
        star_card.save!
        expect(star_card.safe_set_keys).to eq("#{all_type_star} SELF-Xanew_card")
      end
    end

    context "with junction cards" do
      let(:plus_card) { Card.new(name: "Iliad+author") }

      it "includes 5 sets when new" do
        expect(plus_card.safe_set_keys)
          .to eq("ALL ALL_PLUS TYPE-rich_text RIGHT-author TYPE_PLUS_RIGHT-book-author")
      end

      it "includes 6 sets when real" do
        plus_card.save!
        expect(plus_card.safe_set_keys)
          .to eq("ALL ALL_PLUS TYPE-rich_text RIGHT-author TYPE_PLUS_RIGHT-book-author "\
                 "SELF-iliad-author")
      end
    end
  end

  describe "#label" do
    it "returns label for name" do
      expect(Card.new(name: "address+*right").label).to eq(%(All "+address" cards))
    end
  end
end
