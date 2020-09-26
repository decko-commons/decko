# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Rules do
  before do
    Card::Auth.signin Card::WagnBotID
  end

  describe "setting data setup" do
    it "makes Set of +*type" do
      Card.create! name: "SpeciForm", type: "Cardtype"
      expect(Card.create!(name: "SpeciForm+*type").type_code).to eq(:set)
    end
  end

  describe "#rule" do
    it "retrieves Set based value" do
      Card.create name: "Book+*type+*help", content: "authorize"
      help_rule = Card.new(type: "Book").rule(:help)
      expect(help_rule).to eq("authorize")
    end

    it "retrieves single values" do
      Card.create! name: "banana+*self+*help", content: "pebbles"
      expect(Card["banana"].rule(:help)).to eq("pebbles")
    end
  end

  describe "#setting_codenames_by_group" do
    before do
      @pointer_settings = %i[options options_label input]
    end
    it "doesn't fail on nonexistent trunks" do
      codenames = Card.new(name: "foob+*right").setting_codenames_by_group
      expect(codenames.class).to eq(Hash)
    end

    it "returns universal setting names for non-pointer set" do
      skip "Different api, we should just put the tests in a new spec for that"
      snbg = Card.fetch("*star").setting_codenames_by_group
      # warn "snbg #{snbg.class} #{snbg.inspect}"
      expect(snbg.keys.length).to eq(4)
      expect(snbg.keys.first).to be_a Symbol
      expect(snbg.keys.member?(:pointer)).not_to be_truthy
    end
  end

  describe "user specific rules" do
    before do
      Card::Auth.signin "Joe User"
    end

    it "user rule is recognized as rule" do
      Card::Auth.as_bot do
        card = Card.create name: "Book+*type+Joe User+*follow",
                           content: "[[*always]]"
        expect(card.is_rule?).to be_truthy
      end
    end

    it "retrieves Set based value" do
      Card::Auth.as_bot do
        Card.create name: "Book+*type+Joe User+*follow", content: "[[*always]]"
      end
      expect(Card.new(type: "Book").preference(:follow)).to eq("[[*always]]")
    end

    it "retrieves user independent Set based value" do
      Card::Auth.as_bot do
        Card.create name: "Book+*type+*all+*follow", content: "[[Home]]"
      end
      expect(Card.new(type: "Book").preference(:follow)).to eq("[[Home]]")
    end

    it "uses *all user rule when no super.s"

    it "user-specific value overwrites user-independent value" do
      Card::Auth.as_bot do
        Card.create name: "Book+*type+Joe User+*follow", content: "[[*never]]"
        Card.create name: "Book+*type+*all+*follow", content: "[[*always]]"
      end
      expect(Card.new(type: "Book").preference(:follow)).to eq("[[*never]]")
    end

    describe "#all_user_ids_with_rule_for" do
      it "returns all user with values for the given Set and rule" do
        Card::Auth.as_bot do
          Card.create(name: "Book+*type+Joe User+*follow", content: "[[Home]]")
          Card::Auth.signin "Joe Admin"
          Card.create(name: "Book+*type+Joe Admin+*follow", content: "[[Home]]")
          user_ids = Card::Rule.all_user_ids_with_rule_for(
            Card.fetch("Book+*type"), :follow
          )
          expect(user_ids.sort).to eq(
            [Card["Joe User"].id, Card["Joe Admin"].id].sort
          )
        end
      end
    end
  end
end
