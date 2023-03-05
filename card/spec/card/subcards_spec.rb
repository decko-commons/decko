# -*- encoding : utf-8 -*-

RSpec.describe Card::Subcards do
  let(:card) { Card["A"] }

  describe "creating card with subcards", as_bot: true do
    it "works with subcard hash" do
      create "card with subs", subcards: { "+sub1" => { content: "this is sub1" } }
      expect(Card["card with subs+sub1"].content).to eq "this is sub1"
    end

    it "check name-key bug" do
      create "Matthias", subcards: { "+name" => "test" }
      expect(Card).to exist("Matthias+name")
    end

    it "works with content string" do
      create "card with subs", subcards: { "+sub1" => "this is sub1" }
      expect(Card["card with subs+sub1"].content).to eq "this is sub1"
    end

    it "check unstable key bug" do
      create "Matthias", subcards: { "+name" => "test" }
      expect(Card).to exist("Matthias+name")
    end

    it "works with +name key in args" do
      create "card with subs", "+sub1" => { content: "this is sub1" }
      expect(Card["card with subs+sub1"].content).to eq "this is sub1"
    end

    it "handles more than one level" do
      create "card with subs", "+sub1" => { "+sub2" => "this is sub2" }
      expect(Card["card with subs+sub1+sub2"].content).to eq "this is sub2"
    end

    it "handles compound names" do
      create "superman", "+sub1+sub2" => "this is sub2"
      expect(Card["superman+sub1"]).to be_truthy
      expect(Card["superman+sub1+sub2"].content).to eq "this is sub2"
    end

    it "keeps plural of left part" do
      create "supermen", content: "something", subcards: { "+pseudonym" => "clark" }
      expect(Card["supermen+pseudonym"].name).to eq "supermen+pseudonym"
    end

    it "cleans the cache for autonaming case" do
      create "Book+*type+*autoname", content: "Book_1", type_id: Card::PhraseID

      card = Card.create! type: "Book", subcards: { "+editable" => "yes" }
      expect(card.errors).to be_empty
      expect_card("#{card.name}+editable").to exist

      card = Card.create! type: "Book", subcards: { "+editable" => "sure" }
      expect(card.errors).to be_empty
      expect_card("#{card.name}+editable").to exist
    end
  end

  describe "#field" do
    def local_content name
      Card.fetch(name, new: {}, local_only: true).content
    end

    it "works with string" do
      card.field "sub", content: "this is a sub"
      expect(local_content("#{card.name}+sub")).to eq "this is a sub"
    end

    it "works with codename" do
      card.field :phrase, content: "this is a sub"
      expect(local_content("A+phrase")).to eq "this is a sub"
    end
  end

  describe "#field" do
    it "works with string" do
      card.field "sub", content: "this is a sub"
      expect(card.field("sub").content).to eq "this is a sub"
    end

    it "works with codename" do
      card.field :phrase, content: "this is a sub"
      expect(card.field(":phrase").content).to eq "this is a sub"
    end

    it "works together with type change" do
      card = create "card with subs", "+sub1" => "first"
      card.update! type_id: Card::PhraseID, "+sub1" => "second"
      expect(Card["card with subs+sub1"].content).to eq "second"
    end

    it "handles codenames" do
      create "card with subs", fields: { title: "title 1" }
      expect_card("card with subs+*title").to exist.and have_db_content "title 1"
    end

    it "handles nested fields" do
      create "card with subs",
             fields: { "nested" => { fields: { title: "title 2" } } }
      expect_card("card with subs+nested+*title").to exist.and have_db_content "title 2"
    end

    it "handles nested codenames" do
      create "card with subs", fields: { title: "new title" }
      expect_card("card with subs+*title").to exist.and have_db_content "new title"
    end
  end

  describe "#add" do
    it "adds a subcard" do
      card.subcard "sub", content: "sub content"
      card.save!
      expect_card("sub").to have_db_content "sub content"
    end

    it "takes the changes of the last subcard call" do
      card.subcard "sub", content: "sub content 1"
      card.subcard "sub", content: "sub content 2"
      card.save!
      expect_card("sub").to have_db_content "sub content 2"
    end

    it "attribute changes to left card are possible", as_bot: true do
      create_with_event "left part+right part", :prepare_to_store do
        subcard "left part", type_id: Card::PhraseID
      end
      expect_card("left part").to have_type Card::PhraseID
      expect_card("left part+right part").to have_left_id "left part".card_id
    end
  end

  describe "two levels of subcards" do
    it "creates cards with subcards with subcards", as_bot: true do
      create_with_event "test", :validate do
        field("first-level").field "second-level", content: "yeah"
      end
      expect_card("test+first-level+second-level").to have_db_content "yeah"
    end

    it "creates cards with subcards with subcards using codenames", as_bot: true do
      create_with_event "test", :validate do
        field(:children).field :title, content: "yeah"
      end
      expect_card("test+*child+*title").to have_db_content "yeah"
    end
  end

  describe "card#update with subcards arg" do
    it "creates subcards if they don't already exist" do
      "A".card.update! subcards: { "+peel" => { content: "yellow" } }

      peel = "A+peel".card
      expect(peel.content).to eq("yellow")
      expect(peel.creator_id).to eq("joe user".card_id)
    end
  end

  # TODO: move to a more appropriate place (renaming no longer uses subcards)
  describe "handle_subcard_errors" do
    let(:referee) { Card["T"] }

    it "deals with renaming, even when children have content changing" do
      Card.create! name: "A+alias", content: "A"
      expect { Card["A"].update! name: "AABAA" }.not_to raise_error
    end
  end
end
