# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Trash do
  describe "deletion basics" do
    before do
      Card::Auth.as_bot do
        @c = Card["A"]
        @c.delete!
      end
    end

    it "is in the trash" do
      expect(@c.trash).to be_truthy
    end

    it "comes out of the trash when a plus card is created" do
      Card::Auth.as_bot do
        Card.create(name: "A+*acct")
        c = Card["A"]
        expect(c.trash).to be_falsey
      end
    end
  end

  it "descendant removal" do
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

  it "deletes children under a set", as_bot: true do
    create_set "Book+value+*type plus right",
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
    it "certain 'all rules' should be indestructable" do
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
end
