# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::MirroredList do
  subject { Card.fetch("Parry Hotter+authors").item_names.sort }

  before do
    Card::Auth.as_bot do
      create_mirror_list "Stam Broker+books"
      create_mirrored_list "Parry Hotter+authors", "[[Darles Chickens]]\n[[Stam Broker]]"
    end
  end

  let :authors do
    Card.fetch("Parry Hotter+authors").item_names.sort
  end

  describe "Parry Hotter+authors" do
    context "when 'Parry Hotter' is added to Joe-Ann Rolwings's books" do
      before do
        create_author "Joe-Ann Rolwing"
        create_mirror_list "Joe-Ann Rolwing+books", "[[Parry Hotter]]"
      end
      it do
        is_expected.to eq(
          ["Darles Chickens", "Joe-Ann Rolwing", "Stam Broker"]
        )
      end
    end

    context "when 'Parry Hotter' is dropped from Stam Brokers's books" do
      specify "Stam Broker is no longer an author of Parry Hotter", as_bot: true do
        Card["Stam Brokers+books"].update! content: "[[50 grades of shy]]"
        expect(authors).to contain_exactly "Darles Chickens"
      end
    end

    context "when Stam Broker is deleted" do
      before do
        Card["Stam Broker"].delete
      end
      it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
    end
    context "when the cardtype of Stam Broker changed" do
      it "raises an error" do
        @card = Card["Stam Broker"]
        @card.update type_id: Card::BasicID
        expect(@card.errors[:type].first).to match(
          /can't be changed because .+ is referenced by list/
        )
      end
    end
    context "when the name of Parry Hotter changed to Parry Moppins" do
      before do
        Card["Parry Hotter"].update! name: "Parry Moppins"
      end
      subject do
        Card.fetch("Parry Moppins+authors").item_names.sort
      end

      it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
    end

    context "when the name of Stam Broker changed to Stam Trader" do
      before do
        Card::Auth.as_bot do
        Card["Stam Broker"].update!(
          name: "Stam Trader", update_referers: true
        )
        end
      end
      it { is_expected.to eq ["Darles Chickens", "Stam Trader"] }
    end

    # if content is invalid then fail
    context "when Stam Broker+books changes to Stam Broker+poems" do
      it "raises error because content is invalid" do
        # FIXME: - bad description; content is not changed
        expect do
          Card["Stam Broker+books"].update! name: "Stam Broker+poems"
        end.to raise_error(ActiveRecord::RecordInvalid,
                           /Name must have a cardtype name as right part/)
      end
    end
    context "when Stam Broker+books changes to Stam Broker+not a type" do
      it "raises error because name needs cardtype name as right part" do
        expect do
          Card["Stam Broker+books"].update!(
            name: "Stam Broker+not a type"
          )
        end.to raise_error(ActiveRecord::RecordInvalid,
                           /Name must have a cardtype name as right part/)
      end
    end

    context "when the cartype of Parry Hotter changed" do
      before do
        Card["Parry Hotter"].update! type_id: Card::BasicID
      end
      it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
    end
    context "when Parry Hotter+authors to Parry Hotter+rich_text" do
      it "raises error because content is invalid" do
        expect do
          Card["Parry Hotter+authors"].update!(
            name: "Parry Hotter+rich_text"
          )
        end.to raise_error(ActiveRecord::RecordInvalid,
                           /Name name conflicts with list items/)
      end
    end
  end

  describe "'mirror list' entry added that doesn't have a list" do
    context "when '50 grades of shy is added to Stam Broker's books" do
      before do
        Card["Stam Broker+books"].add_item! "50 grades of shy"
      end
      it "creates '50 grades of shy+authors" do
        authors = Card["50 grades of shy+authors"]
        expect(authors).to be_truthy
        expect(authors.item_names).to eq ["Stam Broker"]
      end
    end
  end

  context "when the name of the cardtype books changed" do
    before do
      Card["book"].update!(
        name: "film", update_referers: true
      )
    end
    it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
  end

  context "when the name of the cardtype authors changed" do
    before do
      Card["author"].update!(
        name: "publisher", update_referers: true
      )
    end
    specify do
      expect(Card.fetch("Parry Hotter+publisher").item_names)
        .to contain_exactly("Darles Chickens", "Stam Broker")
    end
  end
end
