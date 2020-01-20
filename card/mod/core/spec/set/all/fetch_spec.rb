# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Fetch do
  describe "#fetch" do
    it "returns and caches existing cards" do
      card_double = class_double("Card")
      expect(Card.fetch("A")).to be_instance_of(Card)
      expect(Card.cache.read("a")).to be_instance_of(Card)
      expect(card_double).not_to receive(:find_by_key)
      expect(Card.fetch("A")).to be_instance_of(Card)
    end

    it "returns nil and caches missing cards" do
      expect(Card.fetch("Zork")).to be_nil
      expect(Card.cache.read("zork").new_card?).to be_truthy
      expect(Card.fetch("Zork")).to be_nil
    end

    it "returns nil and caches trash cards" do
      Card::Auth.as_bot do
        card_double = class_double("Card")
        Card.fetch("A").delete!
        expect(Card.fetch("A")).to be_nil
        expect(card_double).not_to receive(:find_by_key_and_trash)
        expect(Card.fetch("A")).to be_nil
      end
    end

    it "returns and caches builtin cards" do
      expect(Card.fetch("*head")).to be_instance_of(Card)
      expect(Card.cache.read("*head")).not_to be_nil
    end

    it "returns virtual cards and caches them as missing" do
      Card::Auth.as_bot do
        card = Card.fetch("Joe User+*email")
        expect(card).to be_a(Card).and have_name "Joe User+*email"
        expect(card.format.render_raw).to eq("joe@user.com")
      end
      # card.content.should == 'joe@user.com'
      # cached_card = Card.cache.read('joe_user+*email')
      # cached_card.missing?.should be_true
      # cached_card.virtual?.should be_true
    end

    it "fetches virtual cards after skipping them" do
      expect(Card["A+*self"]).to be_nil
      expect(Card.fetch("A+*self")).not_to be_nil
    end

    it "fetches newly virtual cards", as_bot: true do
      expect(Card.fetch("A+virtual")).to be_nil
      create "virtual+*right+*structure"
      expect(Card.fetch("A+virtual")).not_to be_nil
    end

    it "fetches virtual set cards" do
      aself = Card.fetch("A+*self")
      Card::Cache.reset_all
      Card.fetch "A+*self"

      expect(aself.set_names).to include("Set+*type")
    end

    it "fetches structured cards" do
      Card::Auth.as_bot do
        Card.create! name: "y+*right+*structure", content: "Formatted Content"
        Card.create! name: "a+y", content: "DB Content"
      end
      card = Card.fetch("a+y")
      expect(card).to be_real.and have_content("Formatted Content").and have_db_content("DB Content")
    end

    it "handles name variants of cached cards" do
      expect(Card.fetch("yomama+*self").name).to eq("yomama+*self")
      expect(Card.fetch("YOMAMA+*self").name).to eq("YOMAMA+*self")
      expect(Card.fetch("yomama", new: {}).name).to eq("yomama")
      expect(Card.fetch("YOMAMA", new: {}).name).to eq("YOMAMA")
      expect(Card.fetch("yomama!", new: { name: "Yomama" }).name)
        .to eq("Yomama")
    end

    it "fetches junction of names" do
      card = Card.fetch "A", "B"
      expect(card).to be_instance_of(Card)
      expect(card.name).to eq "A+B"
    end

    it "fetches junction of string, id, and codename" do
      card = Card.fetch "Book", Card.fetch_id(:type), :structure
      expect(card).to be_instance_of(Card)
      expect(card.name).to eq "Book+*type+*structure"
    end

    it "fetches junction of name, card object, and codename" do
      card = Card.fetch "Book".to_name, Card.fetch(:type), :structure
      expect(card).to be_instance_of(Card)
      expect(card.name).to eq "Book+*type+*structure"
    end

    it "does not recurse infinitely on template templates" do
      expect(Card.fetch("*structure+*right+*structure")).to be_nil
    end

    it "expires card and dependencies on save" do
      # Card.cache.dump # should be empty
      Card.cache.soft.reset
      expect(Card.cache.soft.store.keys).to eq([])

      Card::Auth.as_bot do
        a = Card.fetch("A")
        expect(a).to be_instance_of(Card)

        # expires the saved card
        expect(a).to receive(:expire).and_call_original
        # expect().to receive(:delete).with('a#SUBCARDS#').and_call_original
        # expires plus cards
        # expect(Card.cache).to receive(:delete).with('c+a')
        # expect(Card.cache).to receive(:delete).with('d+a')
        # expect(Card.cache).to receive(:delete).with('f+a')
        # expect(Card.cache).to receive(:delete).with('a+b')
        # expect(Card.cache).to receive(:delete).with('a+c')
        # expect(Card.cache).to receive(:delete).with('a+d')
        # expect(Card.cache).to receive(:delete).with('a+e')
        # expect(Card.cache).to receive(:delete).with('a+b+c')

        # expired including? cards
        # expect(Card.cache).to receive(:delete).with('x').exactly(2).times
        # expect(Card.cache).to receive(:delete).with('y').exactly(2).times
        a.save!
      end
    end

    describe "default option" do
      context "when card doesn't exist" do
        it "initializes new cards" do
          card = Card.fetch "non-existent",
                            new: { default_content: "default content" }
          expect(card.db_content).to eq "default content"
        end
      end
      context "when new card exist" do
        it "doesn't change anything" do
          Card.new name: "new card",
                   "+sub" => { content: "some content" }
          card = Card.fetch "new card+sub",
                            new: { default_content: "new content" }
          expect(card.db_content).to eq "some content"
        end
      end
    end

    describe "preferences" do
      before do
        Card::Auth.signin Card::WagnBotID
      end

      it "prefers db cards to pattern virtual cards" do
        Card.create! name: "y+*right+*structure",
                     content: "Formatted Content"
        Card.create! name: "a+y", content: "DB Content"
        card = Card.fetch("a+y")
        expect(card).to be_not_virtual.and have_db_content "DB Content"
        expect(card.rule(:structure)).to eq("Formatted Content")
      end

      it "prefers a pattern virtual card to trash cards" do
        Card.create!(name: "y+*right+*structure", content: "Formatted Content")
        Card.create!(name: "a+y", content: "DB Content")
        Card.fetch("a+y").delete!

        card = Card.fetch("a+y")
        expect(card).to be_virtual.and have_content "Formatted Content"
      end

      it "recognizes pattern overrides" do
        # ~~~ create right rule
        Card.create!(name: "y+*right+*structure", content: "Right Content")
        card = Card.fetch("a+y")
        expect(card).to be_virtual.and have_content "Right Content"

        #        warn 'creating template'
        tpr = Card.create! name: "RichText+y+*type plus right+*structure",
                           content: "Type Plus Right Content"
        card = Card.fetch("a+y")
        expect(card).to be_virtual.and have_content "Type Plus Right Content"

        # ~~~ delete type plus right rule
        tpr.delete!
        card = Card.fetch("a+y")
        expect(card).to be_virtual.and have_content "Right Content"
      end

      it "does not hit the database for every fetch_virtual lookup" do
        card_double = class_double("Card")
        Card.create!(name: "y+*right+*structure", content: "Formatted Content")
        Card.fetch("a+y")
        expect(card_double).not_to receive(:find_by_key)
        Card.fetch("a+y")
      end

      it "does not be a new_record after being saved" do
        Card.create!(name: "growing up")
        card = Card.fetch("growing up")
        expect(card.new_record?).to be_falsey
      end
    end

    describe "default_content option" do
      context "when card doesn't exist" do
        it "initializes card with default content" do
          card = Card.fetch "non-existent",
                            new: { default_content: "default content" }
          expect(card).to have_db_content "default content"
        end
      end
      context "when new card exist" do
        it "doesn't change content" do
          Card.new name: "new card", "+sub" => { content: "some content" }
          card = Card.fetch "new card+sub", new: { default_content: "new content" }
          expect(card).to have_db_content "some content"
        end
      end
    end
  end

  describe "#fetch new: { ... }" do
    it "returns a new card if it doesn't find one" do
      new_card = Card.fetch "Never Seen Me Before", new: {}
      expect(new_card).to be_a(Card).and be_a_new_record
      expect { new_card.save! }.to increase_card_count.by(1)
    end

    it "returns a card if it finds one" do
      new_card = Card.fetch "A+B", new: {}
      expect(new_card).to be_a(Card).and be_real
      expect { new_card.save! }.not_to increase_card_count
    end

    it "takes a second hash of options as new card options" do
      new_card = Card.fetch "Never Before", new: { type: "Image" }
      expect(new_card).to be_a(Card).and be_a_new_record
                                            .and have_type(:image)
      expect(Card.fetch("Never Before", new: {})).to have_type(:basic)
    end
  end

  describe "#fetch_virtual" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "testsearch+*right+*structure",
                     content: '{"plus":"_self"}', type: "Search"
      end
    end
    it "finds cards with *right+*structure specified" do
      expect(Card.fetch("A+testsearch".to_name))
        .to be_virtual.and have_type(:search_type)
                              .and have_content '{"plus":"_self"}'
    end
    context "fetched virtual card with new args" do
      it "fetchs the virtual card with type set in patterns" do
        Card.fetch "+testsearch", new: { name: "+testsearch",
                                         supercard: Card["home"] }

        c = Card.fetch("Home+testsearch".to_name)
        expect(c).to be_virtual.and have_type(:search_type)
                                       .and have_content('{"plus":"_self"}')

        patterns = c.instance_variable_get("@patterns").map(&:to_s)
        expect(patterns).to include("Search+*type")
      end
    end
  end

  describe "#id" do
    it "handles integer args" do
      expect(Card.id(1234)).to eq(1234)
    end

    it "handles card args" do
      a = Card["A"]
      expect(Card.id(a)).to eq(a.id)
    end

    it "handles symbols" do
      expect(Card.id(:structure)).to eq(Card::StructureID)
    end
  end

  describe "#exists?" do
    it "is true for cards that are there" do
      expect(Card.exists?("A")).to eq(true)
    end

    it "is false for cards that aren't" do
      expect(Card.exists?("Mumblefunk is gone")).to eq(false)
    end
  end

  describe "#fetch_name" do
    example "symbol" do
      expect(Card.fetch_name(:all)).to eq "*all"
    end

    example "string" do
      expect(Card.fetch_name("home")).to eq "Home"
    end

    example "id" do
      expect(Card.fetch_name(Card::BasicID)).to eq "RichText"
    end

    example "invalid id" do
      expect(Card.fetch_name("~1836/[[/assets/fonts")).to be_nil
    end

    example "array" do
      expect(Card.fetch_name(%w[a b])).to eq "A+B"
    end

    example "param list" do
      expect(Card.fetch_name("fruit", :type, "*create")).to eq "Fruit+*type+*create"
    end

    example "name doesn't exist" do
      expect(Card.fetch_name("unknown_name")).to eq nil
    end

    example "fallback policy" do
      name = Card.fetch_name("unknown_name") { "Unknown Name" }
      expect(name).to eq "Unknown Name"
    end

    it "doesn't fetch virtual names" do
      expect(Card.fetch_name(:all, :self, :create)).to eq nil
    end
  end
end
