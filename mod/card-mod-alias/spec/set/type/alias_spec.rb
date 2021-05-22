RSpec.describe Card::Set::Type::Alias do
  let :new_target do
    Card.create!(name: "New A").tap do |t|
      new_alias(t.name).save!
    end
  end

  def new_alias target="A"
    Card.new name: "Alex", type: "Alias", content: target
  end

  describe "event: validate_alias_source" do
    it "disallows compound names of alias" do
      new_alias = Card.create name: "foo+bar", type_code: :alias
      expect(new_alias.errors[:name].first).to match(/not a compound/)
    end
  end

  describe "event: validate_alias_target" do
    it "disallows compound names of alias" do
      a = new_alias "foo+bar"
      a.validate
      expect(a.errors[:content].first).to match(/aliased to a.*simple/)
    end
  end

  describe "alias?" do
    it "is true for simple Alias cards" do
      expect(card_subject).to be_alias
    end

    it "is false for simple non-Alias cards" do
      expect(Card["A"]).not_to be_alias
    end

    it "is false for compound non-alias cards" do
      expect(Card["A+B"]).not_to be_alias
    end

    it "is true for compound Alias cards" do
      new_target
      expect(Card.fetch("Alex+B", new: {})).to be_alias
    end
  end
end
