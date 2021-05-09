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
      expect("*a".to_name).to be_star
    end

    it "doesn't recognize star cards with plusses" do
      expect("*a+*b".to_name).not_to be_star
    end

    it "recognizes rstar cards" do
      expect("a+*a".to_name).to be_rstar
    end

    it "doesn't recognize star cards as rstar" do
      expect("*a".to_name).not_to be_rstar
    end

    it "doesn't recognize non-star or star left" do
      expect("*a+a".to_name).not_to be_rstar
    end
  end

  describe "trait_name?" do
    it "returns true for content codename" do
      expect("bazoinga+*right+*structure".to_name).to(
        be_trait_name(:structure)
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
    describe ".[]" do
      it "translates simple codenames" do
        expect(described_class[":self"]).to eq "*self"
      end

      it "translates simple ids" do
        expect(described_class["~#{Card::SelfID}"]).to eq "*self"
      end

      it "translates junctions of codenames and ids" do
        expect(described_class["A+~#{Card::SelfID}+:default"]).to eq "A+*self+*default"
      end

      it "interprets symbols as codenames" do
        expect(described_class[:self]).to eq "*self"
      end

      it "interprets integers as ids" do
        expect(described_class[Card::SelfID]).to eq "*self"
      end

      it "interprets array items as name parts" do
        expect(described_class[["A", Card::SelfID, :default]]).to eq "A+*self+*default"
      end

      example "nil" do
        expect(described_class[nil]).to eq ""
      end

      it "fails for TrueClass" do
        expect { described_class[true] }
          .to raise_error ArgumentError
      end
    end

    describe ".new" do
      it "doesn't interpret symbols as codenames" do
        expect(described_class.new(:no_codename)).to eq "no_codename"
      end

      it "doesn't interpret integers as ids" do
        expect(described_class.new(25)).to eq "25"
      end

      it "doesn't interpret symbols and integers in arrays" do
        expect(described_class.new(["A", :no_codename, 5])).to eq "A+no_codename+5"
      end

      it "interprets ~ as id" do
        expect(described_class.new("~#{Card::SelfID}")).to eq "*self"
      end

      it "interprets : as codename" do
        expect(described_class.new(":self")).to eq "*self"
      end

      it "interprets ~ and : in arrays" do
        expect(described_class.new(["A", ":self", "5"])).to eq "A+*self+5"
      end

      it "fails for non-existent id" do
        expect { described_class.new("~5000000") }
          .to raise_error(Card::Error::NotFound, "id doesn't exist: 5000000")
      end

      it "handles id out of range" do
        expect { described_class.new("~250000000000") }
          .to raise_error(Card::Error::NotFound, "id doesn't exist: 250000000000")
      end

      it "fails for non-existent codename" do
        expect { described_class.new(":no_codename") }
          .to raise_error(Card::Error::CodenameNotFound)
      end

      it "creates empty name for nil" do
        expect(described_class.new(nil)).to eq ""
      end
    end
  end

  describe "part creation" do
    it "creates parts", as_bot: true do
      create "left+right"
      expect(Card.fetch("right")).to be_truthy
    end

    it "translates codenames in strings" do
      expect("A+:self".to_name.key).to eq "a+*self"
    end

    it "translates codenames in arrays" do
      expect(["A", ":self"].to_name.key).to eq "a+*self"
    end

    it "translates id" do
      expect("A+~#{Card::SelfID}".to_name.key).to eq "a+*self"
    end
  end
end
