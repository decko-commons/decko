RSpec.describe Card::Set::All::Account do
  describe "parties" do
    it "for Wagn Bot", with_user: Card::WagnBotID do
      expect(Card::Auth.current.parties.sort)
        .to eq([Card::WagnBotID, Card::AnyoneSignedInID])
    end

    it "for Anonymous", with_user: Card::AnonymousID do
      expect(Card::Auth.current.parties.sort).to eq([Card::AnonymousID])
    end

    context "for Joe User" do
      before do
        @joe_user_card = Card::Auth.current
        @parties = @joe_user_card.parties # NOTE: must be called to test resets
      end

      it "initially has only auth, shark and self" do
        expect(@parties)
          .to eq([Card::AnyoneSignedInID, Card::SharkID, @joe_user_card.id])
      end

      it "updates when new roles are set" do
        r1 = Card["r1"]
        r1_members = Card["r1", :members]

        Card::Auth.as_bot { r1_members.items = [@joe_user_card.id] }
        Card::Cache.restore
        # simulate new request
        # clears local cache, where, eg, @parties would still be cached on card

        Card::Auth.signin Card::Auth.current_id
        # simulate new request
        # current_id assignment clears several class variables

        new_parties = [Card::AnyoneSignedInID, Card::SharkID, r1.id, @joe_user_card.id]
        expect(Card["Joe User"].parties).to eq(new_parties)
        # @parties regenerated, now with correct values

        expect(Card::Auth.current.parties).to eq(new_parties)
        # @joe_user_card.refresh(force=true).parties.should == new_parties
        # should work, but now superfluous?
      end
    end
  end

  describe "among?" do
    it "is true for self" do
      expect(Card::Auth.current).to be_among([Card::Auth.current_id])
    end
  end

  describe "+*email" do
    it "creates a card and account card" do
      jadmin = Card["joe admin"]
      Card::Auth.signin jadmin.id
      # simulate login to get correct from address

      # Card::Env[:params] = { email: { subject: "Hey Joe!",
      #                                 message: "Come on in." } }
      Card.create! name: "Joe New",
                   type_id: Card::UserID,
                   "+*account" => { "+*email" => "joe@new.com" }

      c = Card["Joe New"]
      u = Card::Auth.find_account_by_email("joe@new.com")

      expect(c.account).to eq(u)
      expect(c.type_id).to eq(Card::UserID)
    end
  end

  context "updates" do
    let(:card) { Card["Joe User"] }
    let(:account) { card.account }

    it "handles email updates" do
      card.update! "+*account" => { "+*email" => "joe@user.co.uk" }
      expect(account.email).to eq("joe@user.co.uk")
    end

    it "lets Wagn Bot block accounts", :as_bot do
      card.account.status_card.update! content: "blocked"
      expect(account).to be_blocked
    end

    it "does not allow a user to block or unblock himself" do
      expect do
        account.status_card.update! content: "blocked"
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Permission denied You don't have " \
                         "permission to change the status of your own account")
      expect(account).not_to be_blocked
    end
  end

  describe "#read_rules" do
    before(:all) do
      @read_rules = Card["joe_user"].read_rules
    end

    it "*all+*read should apply to Joe User" do
      expect(@read_rules).to be_member(Card.fetch("*all+*read").id)
    end

    it "12 more should apply to Joe Admin" do
      # includes lots of account rules...
      Card::Auth.as("joe_admin") do
        ids = Card::Auth.as_card.read_rules
        expect(ids.length).to eq(@read_rules.size + 11)
      end
    end
  end
end
