# -*- encoding : utf-8 -*-

RSpec.describe Card::Rule::All do
  before do
    Card::Auth.signin Card::DeckoBotID
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
      expect(snbg.keys).not_to be_member(:pointer)
    end
  end

  describe "user specific rules" do
    before do
      Card::Auth.signin "Joe User"
    end

    let(:preference) { Card.new(type: "Book").preference :follow }

    def follow who, whn
      Card.create name: "Book+*type+#{who}+*follow", content: whn
    end

    it "user rule is recognized as rule" do
      expect(follow("Joe User", "*always")).to be_rule
    end

    it "retrieves Set based value" do
      follow "Joe User", "*always"
      expect(preference).to eq("*always")
    end

    it "retrieves user independent Set based value" do
      follow "*all", "*always"
      expect(preference).to eq("*always")
    end

    it "user-specific value overwrites user-independent value" do
      follow "Joe User", "*never"
      follow "*all", "*always"
      expect(preference).to eq("*never")
    end

    describe "#all_user_ids_with_rule_for" do
      it "returns all user with values for the given Set and rule" do
        follow "Joe User", "*always"
        Card::Auth.signin "Joe Admin"
        follow "Joe Admin", "*always"
        user_ids = Card::Rule.all_user_ids_with_rule_for Card.fetch("Book+*type"), :follow
        expect(user_ids.sort).to eq([Card.id("Joe User"), Card.id("Joe Admin")].sort)
      end
    end
  end
end
