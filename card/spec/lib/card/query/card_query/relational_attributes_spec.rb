require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::RelationalAttributes do
  include QuerySpecHelper
  A_JOINEES = %w(B C D E F).freeze

  each_fasten do |fastn|
    context "with fasten: #{fastn}" do
      let(:fasten) { fastn }

      describe "type" do
        user_cards = [
            "Big Brother", "Joe Admin", "Joe Camel", "Joe User", "John",
            "Narcissist", "No Count", "Optic fan", "Sample User", "Sara",
            "Sunglasses fan", "u1", "u2", "u3"
        ].sort

        it "finds cards of this type" do
          @query = { type: "_self", context: "User" }
          is_expected.to eq(user_cards)
        end

        it "finds User cards " do
          @query = { type: "User" }
          is_expected.to eq(user_cards)
        end

        it "handles casespace variants" do
          @query = { type: "users" }
          is_expected.to eq(user_cards)
        end
      end

      describe "plus/part" do

        it "finds plus cards" do
          @query = { plus: "A" }
          is_expected.to eq(A_JOINEES)
        end

        it "finds connection cards" do
          @query = { part: "A" }
          is_expected.to eq(%w(A+B A+C A+D A+E C+A D+A F+A))
        end

        it "finds left connection cards" do
          @query = { left: "A" }
          is_expected.to eq(%w(A+B A+C A+D A+E))
        end

        it "finds right connection cards based on name" do
          @query = { right: "A" }
          is_expected.to eq(%w(C+A D+A F+A))
        end

        it "finds right connection cards based on content" do
          @query = { right: { content: "Alpha [[Z]]" } }
          is_expected.to eq(%w(C+A D+A F+A))
        end
      end

      describe "relative plus/part" do
        it "cleans wql" do
          query = Card::Query.new(part: "_self", context: "A")
          expect(query.statement[:part]).to eq("A")
        end

        it "finds connection cards" do
          @query = { part: "_self", context: "A" }
          is_expected.to eq(%w(A+B A+C A+D A+E C+A D+A F+A))
        end

        it "is able to use parts of nonexistent cards in search" do
          expect(Card["B+A"]).to be_nil
          @query = { left: "_right", right: "_left", context: "B+A" }
          is_expected.to eq(["A+B"])
        end

        it "finds plus cards for _self" do
          @query = { plus: "_self", context: "A" }
          is_expected.to eq(A_JOINEES)
        end

        it "finds plus cards for _left" do
          @query = { plus: "_left", context: "A+B" }
          is_expected.to eq(A_JOINEES)
        end

        it "finds plus cards for _right" do
          @query = { plus: "_right", context: "C+A" }
          is_expected.to eq(A_JOINEES)
        end
      end

      describe "created_by/creator_of" do
        before do
          Card.create name: "Create Test", content: "sufficiently distinctive"
        end

        it "finds Joe User as the card's creator" do
          @query = { creator_of: "Create Test" }
          is_expected.to eq(["Joe User"])
        end

        it "finds card created by Joe User" do
          @query = { created_by: "Joe User", eq: "sufficiently distinctive" }
          is_expected.to eq(["Create Test"])
        end
      end

      describe "edited_by/editor_of" do
        it "finds card edited by joe using subquery" do
          @query = { edited_by: { match: "Joe User" } }
          is_expected.to include("JoeLater", "JoeNow")
        end

        it "finds card edited by Wagn Bot" do
          # this is a weak test, since it gives the name, but different sorting
          # mechanisms in other db setups
          # was having it return *account in some cases and 'A' in others
          @query = { edited_by: "Wagn Bot", name: "A" }
          is_expected.to eq(%w(A))
        end

        it "fails gracefully if user isn't there" do
          @query = { edited_by: "Joe LUser" }
          is_expected.to eq([])
        end

        it "does not give duplicate results for multiple edits" do
          c = Card["JoeNow"]
          c.content = "testagagin"
          c.save
          c.content = "test3"
          c.save!
          @query = { edited_by: "Joe User" }
          is_expected.to include("JoeLater", "JoeNow")
        end

        it "finds joe user among card's editors" do
          @query = { editor_of: "JoeLater" }
          is_expected.to eq(["Joe User"])
        end
      end

      describe "last_edited_by/last_editor_of" do
        before do
          c = Card.fetch("A")
          c.content = "peculicious"
          c.save!
        end

        it "finds Joe User as the card's last editor" do
          @query = { last_editor_of: "A" }
          is_expected.to eq(["Joe User"])
        end

        it "finds card created by Joe User" do
          @query = { last_edited_by: "Joe User", eq: "peculicious" }
          is_expected.to eq(["A"])
        end
      end

      describe "updated_by/updater_of" do
        it "finds card updated by Narcissist" do
          @query = { updated_by: "Narcissist" }
          is_expected.to eq(%w(Magnifier+lens))
        end

        it "finds Narcississt as the card's updater" do
          @query = { updater_of: "Magnifier+lens" }
          is_expected.to eq(%w(Narcissist))
        end

        it "does not give duplicate results for multiple updates" do
          @query = { updater_of: "First" }
          is_expected.to eq(["Wagn Bot"])
        end

        it "does not give results if not updated" do
          @query = { updater_of: "Sunglasses+price" }
          is_expected.to be_empty
        end

        it "'or' doesn't mess up updated_by SQL" do
          @query = { or: { updated_by: "Narcissist" } }
          is_expected.to eq(%w(Magnifier+lens))
        end

        it "'or' doesn't mess up updater_of SQL" do
          @query = { or: { updater_of: "First" } }
          is_expected.to eq(["Wagn Bot"])
        end
      end
    end
  end
end
