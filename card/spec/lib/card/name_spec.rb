# -*- encoding : utf-8 -*-

RSpec.describe Card::Name do
  describe "#valid" do
    it "rejects long names" do
      card = Card.new
      card.name = "1" * 256
      expect(card).not_to be_valid
    end
  end

  describe "Cardnames star handling" do
    it "recognizes star cards" do
      expect("*a".to_name.star?).to be_truthy
    end

    it "doesn't recognize star cards with plusses" do
      expect("*a+*b".to_name.star?).to be_falsey
    end

    it "recognizes rstar cards" do
      expect("a+*a".to_name.rstar?).to be_truthy
    end

    it "doesn't recognize star cards as rstar" do
      expect("*a".to_name.rstar?).to be_falsey
    end

    it "doesn't recognize non-star or star left" do
      expect("*a+a".to_name.rstar?).to be_falsey
    end
  end

  describe "trait_name?" do
    it "returns true for content codename" do
      expect("bazoinga+*right+*structure".to_name.trait_name?(:structure)).to(
        be_truthy
      )
    end

    it "handles arrays" do
      structure =
        "bazoinga+*right+*structure".to_name.trait_name?(:structure, :default)
      expect(structure).to be_truthy
    end

    it "returns false for non-template" do
      structure = "bazoinga+*right+nontent".to_name.trait_name?(:structure)
      expect(structure).to be_falsey
    end
  end

  describe "#absolute" do
    it "does session user substitution" do
      expect("_user".to_name.absolute("A")).to eq(Card::Auth.current.name)
      Card::Auth.as_bot do
        expect("_user".to_name.absolute("A")).to eq(Card::Auth.current.name)
      end
    end
  end


  describe "creation" do
    it "translates simple codenames" do
      expect(Card::Name[":self"]).to eq "*self"
    end

    it "translates simple ids" do
      expect(Card::Name["~#{Card::SelfID}"]).to eq "*self"
    end

    it "translates junctions of codenames and ids" do
      expect(Card::Name["A+~#{Card::SelfID}+:default"]).to eq "A+*self+*default"
    end

    it "interprets symbols as codenames" do
      expect(Card::Name[:self]).to eq "*self"
    end

    it "interprets integers as ids" do
      expect(Card::Name[Card::SelfID]).to eq "*self"
    end

    it "interprets array items as name parts" do
      expect(Card::Name[["A", Card::SelfID, :default]]).to eq "A+*self+*default"
    end
  end

  describe "part creation" do
    it "creates parts" do
      Card::Auth.as_bot do
        Card.create name: "left+right"
      end
      expect(Card.fetch("right")).to be_truthy
    end



    it "translates codenames in strings" do
      expect("A+:self".to_name.key).to eq "a+*self"
    end

    it "translates codenames in arrays" do
      expect(["A", ":self"].to_name.key).to eq "a+*self"
    end

    it "translates id" do
      expect("A+~#{Card.fetch_id(:self)}".to_name.key).to eq "a+*self"
    end
  end
end
