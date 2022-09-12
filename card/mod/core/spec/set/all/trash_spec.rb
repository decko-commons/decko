# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Trash do
  describe "#delete " do
    it "puts card in trash", as_bot: true do
      subj = card_subject
      subj.delete!
      expect(subj.trash).to be_truthy
    end
  end

  describe "event: manage_trash" do
    it "pulls card out of the trash when re-created with same name", as_bot: true do
      card_subject.delete!
      Card.create name: "A+*acct"
      expect(card_subject.trash).to be_falsey
    end
  end

  it "deletes account of user", as_bot: true do
    expect(Card["Sample User", :account]).to be_a Card
    Card["Sample User"].delete!
    expect(Card["Sample User", :account]).not_to be
    # @signup =
    #   create_signup "born to die",
    #                 "+*account" => { "+*email" => "wolf@decko.org", "+*password" => "wolf" }
    # @signup.update!({})
    # Card::Cache.reset_all
    #
    # Card::Auth.as_bot do
    #   expect(Card.search(right: "*account")).not_to be_empty
    #   Card["born to die"].delete!
    # end
    # expect(Card["born to die+*account"]).not_to be
  end

  describe "event: validate_delete" do
    it "certain 'all rules' should be indestructible" do
      rule = "*all+*default"
      expect { Card[rule].delete! }
        .to raise_error(/is an indestructible rule/)

      expect(Card[rule]).to be_a Card
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

    # it "removes children with restricted delete permissions" do
    #   Card::Auth.as_bot do
    #     Card.create! name: ["A", :status] # deleting +status cards requires Help Desk role
    #   end
    #
    #   a = card_subject
    #   as = Card["A", :status]
    #   a.delete!
    #   expect(a.trash).to be_truthy
    #   expect(as.trash).to be_truthy
    # end

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
  end
end
