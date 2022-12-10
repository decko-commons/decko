# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Trash do
  describe "#delete " do
    it "puts card in trash", as_bot: true do
      subj = card_subject
      subj.delete!
      expect(subj.trash).to be_truthy
    end
  end

  it "deletes account of user", as_bot: true do
    expect(Card["Sample User", :account]).to be_a Card
    Card["Sample User"].delete!
    expect(Card["Sample User", :account]).not_to be
  end

  describe "event: validate_delete" do
    it "certain 'all rules' should be indestructible" do
      rule = "*all+*default"
      expect { Card[rule].delete! }
        .to raise_error(/is an indestructible rule/)

      expect(Card[rule]).to be_a Card
    end

    it "prevents deletion without permission" do
      a = "a".card
      Card::Auth.as :anonymous do
        expect(a.ok?(:delete)).to eq(false)
        expect(a.delete).to eq(false)
        expect(a.errors[:permission_denied]).not_to be_empty
        expect("a".card.trash).to eq(false)
      end
    end

    context "card with account" do
      context "with edits" do
        it "is not removable" do
          expect { Card["Joe User"].delete! }
            .to raise_error(/Edits have been made with Joe User's user account/)
        end
      end

      context "without edits" do
        it "is removable" do
          Card::Auth.as "joe_admin" do
            expect { Card["Sample User"].delete! }
              .not_to raise_error
          end
        end
      end

      context "with undeletable child" do
        # NOTE: +*status restricts deletion to Help Desk role
        it "cannot be deleted" do
          Card::Auth.as_bot { Card.create! name: ["A", :status] }
          expect { card_subject.delete! }.to raise_error(/don't have permission/)
        end

        it "cannot be created and deleted in consecutive acts" do
          schmatus = Card::Auth.as_bot do
            Card.create! name: "schmatus", fields: { status: "open" }
          end
          expect { schmatus.delete! }.to raise_error(/don't have permission/)
        end
      end
    end
  end

  describe "event: delete_children" do
    it "removes descendants" do
      create! "born to die"
      create! "born to die+slowly"
      create! "slowly+born to die"
      create! "born to die+slowly+without regrets"

      Card["born to die"].delete!

      expect(Card["born to die"]).to be_nil
      expect(Card["born to die+slowly"]).to be_nil
      expect(Card["slowly+born to die"]).to be_nil
      expect(Card["born to die+slowly+without regrets"]).to be_nil
      expect(Card["slowly"]).to be_a Card
      expect(Card["without regrets"]).to be_a Card

      trashed_dependant = Card.find Card::Lexicon.id("born to die+slowly+without regrets")
      expect(trashed_dependant.trash).to be_truthy
    end

    # TODO: explain what this adds to testing above or remove test.
    it "deletes children under a set", as_bot: true do
      create_set "Book+value+*type plus right"
      book1 = "Richard Mills+Annual Sales+CA+2014"
      book2 = "Richard Mills+Annual Profits+CA+2014"
      create_book book1
      create_book book2
      create! "#{book1}+value"
      create! "#{book2}+value"

      expect(Card["CA"]).to be

      Card["CA"].delete!

      expect(Card["CA"]).not_to be
      expect(Card[book1]).not_to be
      expect(Card["#{book1}+value"]).not_to be
      expect(Card[book2]).not_to be
      expect(Card["#{book2}+value"]).not_to be
    end

    it "handles compound cards", as_bot: true do
      c = Card.create! name: "zz+top"
      "zz".card.delete!
      expect(Card.find(c.id).trash).to be_truthy
      expect("zz".card).to be_nil
    end
  end

  describe "event: manage_trash" do
    it "pulls deleted card from trash when recreating" do
      b_id = "basicname".card_id
      "basicname".card.delete!
      c = Card.create! name: "basicname", content: "revived content"
      expect(c.trash).to eq(false)
      expect(c.actions.count).to eq(3)
      expect(c.nth_action(1).value(:db_content)).to eq("basiccontent")
      expect(c.content).to eq("revived content")
      expect(c.id).to eq(b_id)
    end

    it "pulls parts out of trash when creating compound", as_bot: true do
      card_subject.delete!
      Card.create name: "A+*acct"
      expect(card_subject.trash).to be_falsey
    end

    it "pulls compound card out of trash", as_bot: true do
      %w[a b].card.delete!
      card = Card.create name: "A+B", content: "revived"
      expect(card.trash).to eq(false)
      expect(card.actions.count).to eq(3)
      expect(card.nth_action(1).value(:db_content)).to eq("AlphaBeta")
      expect(card.db_content).to eq("revived")
    end
  end

  specify "card in trash" do
    b = "basicname".card
    b.delete!

    expect(b.trash).to eq(true)
    expect(Card["basicname"]).to eq(nil)
    expect(b.actions.count).to eq(2)
    expect(b.last_change_on(:db_content).value).to eq("basiccontent")
  end

  example "recreate plus card name variant" do
    Card.create(name: "rta+rtb").delete
    Card["rta"].update name: "rta!"
    Card.create! name: "rta!+rtb"
    expect(Card["rta!+rtb"]).to be_a Card
    expect(Card["rta!+rtb"].trash).to be_falsey
    expect(Card.find_by_key("rtb*trash")).to be_nil
  end

  example "multiple trash collision" do
    Card.create(name: "alpha").delete
    3.times do
      b = Card.create(name: "beta")
      b.name = "alpha"
      assert b.save!
      b.delete
    end
  end
end

# NOT WORKING, BUT IT SHOULD
# describe Card, "a part of an unremovable card" do
#  before do
#     Card::Auth.as(Card::WagnBotID)
#     # this ugly setup makes it so A+Admin is the actual user with edits..
#     Card["Wagn Bot"].update! name: "A+Wagn Bot"
#  end
#  it "does not be removable" do
#    @a = Card['A']
#    @a.delete.should_not be_true
#  end
# end
