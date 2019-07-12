# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Pattern do
  describe :set_names do
    it "returns self, type, all for simple cards" do
      Card::Auth.as_bot do
        card = Card.new(name: "AnewCard")
        expect(card.set_names).to eq(["RichText+*type", "*all"])
        card.save!
        card = Card.fetch("AnewCard")
        expect(card.set_names).to eq(["AnewCard+*self", "RichText+*type", "*all"])
      end
    end

    it "returns set names for simple star cards" do
      Card::Auth.as_bot do
        expect(Card.fetch("*update").set_names).to eq(
          [
            "*update+*self", "*star", "Setting+*type", "*all"
          ]
        )
      end
    end

    it "returns set names for junction cards" do
      Card::Auth.as_bot do
        expect(Card.new(name: "Iliad+author").set_names).to eq(
          [
            "Book+author+*type plus right", "author+*right", "RichText+*type",
            "*all plus", "*all"
          ]
        )
      end
    end

    it "returns set names for compound star cards", as_bot: true do
      expect(Card.new(name: "Iliad+*to").set_names).to eq(
        [
          "Book+*to+*type plus right", "*to+*right", "*rstar",
          "List+*type", "*all plus", "*all"
        ]
      )
    end

    it "returns set names for rule cards", as_bot: true do
      expect(Card.new(name: "*all+*create").set_names).to eq(
        [
          "Set+*create+*type plus right", "*create+*right", "*rule", "*rstar",
          "List+*type", "*all plus", "*all"
        ]
      )
    end

    # right place for this?  really need more prototype tests...
    it "handles type plus right prototypes properly" do
      Card::Auth.as_bot do
        sets = Card.fetch("Fruit+flavor+*type plus right").prototype.set_names
        expect(sets.include?("Fruit+flavor+*type plus right")).to be_truthy
      end
    end
  end

  describe :rule_set_keys do
    it "returns correct set names for new cards" do
      card = Card.new name: "AnewCard"
      expect(card.rule_set_keys).to eq(["#{Card::BasicID}+type", "all"])
    end
  end

  describe :safe_set_keys do
    it "returns css names for simple star cards" do
      Card::Auth.as_bot do
        card = Card.new(name: "*AnewCard")
        expect(card.safe_set_keys).to eq("ALL TYPE-rich_text STAR")
        card.save!
        card = Card.fetch("*AnewCard")
        expect(card.safe_set_keys).to eq("ALL TYPE-rich_text STAR SELF-Xanew_card")
      end
    end

    it "returns set names for junction cards" do
      card = Card.new(name: "Iliad+author")
      expect(card.safe_set_keys).to eq(
        "ALL ALL_PLUS TYPE-rich_text RIGHT-author TYPE_PLUS_RIGHT-book-author"
      )
      card.save!
      card = Card.fetch("Iliad+author")
      expect(card.safe_set_keys).to eq(
        "ALL ALL_PLUS TYPE-rich_text RIGHT-author TYPE_PLUS_RIGHT-book-author "\
        "SELF-iliad-author"
      )
    end
  end

  describe :label do
    it "returns label for name" do
      expect(Card.new(name: "address+*right").label)
        .to eq(%(All "+address" cards))
    end
  end
end
