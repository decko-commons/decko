RSpec.describe Card::Set::All::Permissions, "reader rules" do
  describe "reader rules" do
    let :perm_card do
      Card.new name: "Home+*self+*read", type: "Pointer", content: "[[Anyone Signed In]]"
    end

    before do
      perm_card
    end

    it "is *all+*read by default" do
      card = Card.fetch("Home")
      expect(card.read_rule_id).to eq(Card.fetch("*all+*read").id)
      expect(card.who_can(:read)).to eq([Card::AnyoneID])
      Card::Auth.as(:anonymous) { expect(card).to be_ok(:read) }
    end

    it "updates to role ('Anyone Signed In')" do
      name = perm_card.name
      Card::Auth.as_bot { perm_card.save! }
      pc = Card[name]
      card = Card["Home"]
      # warn "card #{name}, #{card.inspect}, #{pc.inspect}"
      expect(pc).to be_truthy
      expect(card.read_rule_id).to eq(pc.id)
      expect(card.who_can(:read)).to eq([Card::AnyoneSignedInID])
      Card::Auth.as(:anonymous) { expect(card).not_to be_ok(:read) }
    end

    it "updates to user ('Joe Admin')" do
      perm_card.db_content = "[[Joe Admin]]"
      Card::Auth.as_bot { perm_card.save! }

      card = Card.fetch("Home")
      expect(card.read_rule_id).to eq(perm_card.id)
      expect(card.who_can(:read)).to eq([Card["joe_admin"].id])
      Card::Auth.as(:anonymous)  { expect(card).not_to be_ok(:read) }
      Card::Auth.as("joe_user")  { expect(card).not_to be_ok(:read) }
      Card::Auth.as("joe_admin") { expect(card).to be_ok(:read) }
      Card::Auth.as_bot          { expect(card).to be_ok(:read) }
    end

    context "when more specific (self) rule is deleted" do
      it "reverts to more general rule"  do
        Card::Auth.as_bot do
          perm_card.save!
          perm_card.delete!
        end
        card = Card.fetch("Home")
        expect(card.read_rule_id).to eq(Card.fetch("*all+*read").id)
      end
    end

    context "when more specific (right) rule is deleted" do
      it "reverts to more general rule" do
        pc = nil
        Card::Auth.as_bot do
          pc = Card.create name: "B+*right+*read", type: "Pointer",
                           content: "[[Anyone Signed In]]"
        end
        expect(pc).to be_truthy
        card = Card.fetch("A+B")
        expect(card.read_rule_id).to eq(pc.id)
        # important to re-fetch to catch issues
        # with detecting change in trash status.
        pc = Card.fetch(pc.name)
        Card::Auth.as_bot { pc.delete }
        card = Card.fetch("A+B")
        expect(card.read_rule_id).to eq(Card.fetch("*all+*read").id)
      end
    end

    context "when more specific rule is renamed" do
      it "reverts to more general rule" do
        Card::Auth.as_bot do
          perm_card.save!
          perm_card.update! name: "Something else+*self+*read"
        end

        card = Card.fetch("Home")
        expect(card.read_rule_id).to eq(Card.fetch("*all+*read").id)
      end
    end

    it "gets not overruled by a more general rule added later" do
      Card::Auth.as_bot do
        perm_card.save!
        c = Card.fetch("Home")
        c.type_id = Card::PhraseID
        c.save!
        Card.create name: "Phrase+*type+*read", type: "Pointer",
                    content: "[[Joe User]]"
      end

      card = Card.fetch("Home")
      expect(card.read_rule_id).to eq(perm_card.id)
    end

    it "gets updated when trunk type change makes " \
       "type-plus-right apply / unapply" do
      perm_card.name = "Phrase+B+*type plus right+*read"
      Card::Auth.as_bot { perm_card.save! }
      expect(Card.fetch("A+B").read_rule_id).to eq(Card.fetch("*all+*read").id)
      c = Card.fetch("A")
      c.type_id = Card::PhraseID
      c.save!
      expect(Card.fetch("A+B").read_rule_id).to eq(perm_card.id)
    end

    it "works with relative settings" do
      Card::Auth.as_bot do
        perm_card.save!
        all_plus = Card.fetch "*all plus+*read", new: { content: "_left" }
        all_plus.save
      end
      c = Card.new(name: "Home+Heart")
      expect(c.who_can(:read)).to eq([Card::AnyoneSignedInID])
      expect(c.permission_rule_id(:read)).to eq(perm_card.id)
      c.save
      expect(c.read_rule_id).to eq(perm_card.id)
    end

    it "gets updated when relative settings change" do
      Card::Auth.as_bot do
        all_plus = Card.fetch "*all plus+*read", new: { content: "_left" }
        all_plus.save
      end
      c = Card.new(name: "Home+Heart")
      expect(c.who_can(:read)).to eq([Card::AnyoneID])
      expect(c.permission_rule_id(:read)).to(
        eq(Card.fetch("*all+*read").id)
      )
      c.save
      expect(c.read_rule_id).to eq(Card.fetch("*all+*read").id)
      Card::Auth.as_bot { perm_card.save! }
      c2 = Card.fetch("Home+Heart")
      expect(c2.who_can(:read)).to eq([Card::AnyoneSignedInID])
      expect(c2.read_rule_id).to eq(perm_card.id)
      expect(Card.fetch("Home+Heart").read_rule_id).to(
        eq(perm_card.id)
      )
      Card::Auth.as_bot { perm_card.delete }
      expect(Card.fetch("Home").read_rule_id).to eq(Card.fetch("*all+*read").id)
      expect(Card.fetch("Home+Heart").read_rule_id).to(
        eq(Card.fetch("*all+*read").id)
      )
    end

    it "insures that class overrides work with relative settings" do
      Card::Auth.as_bot do
        all_plus = Card.fetch "*all plus+*read", new: { content: "_left" }
        all_plus.save
        Card::Auth.as_bot { perm_card.save! }
        c = Card.create(name: "Home+Heart")
        expect(c.read_rule_id).to eq(perm_card.id)
        r = Card.create name: "Heart+*right+*read", type: "Pointer",
                        content: "[[Administrator]]"
        expect(Card.fetch("Home+Heart").read_rule_id).to eq(r.id)
      end
    end

    it "works on virtual+virtual cards" do
      c = Card.fetch("Number+*type+by name")
      expect(c).to be_ok(:read)
    end
  end
end
