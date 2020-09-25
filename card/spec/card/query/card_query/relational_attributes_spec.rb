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

        it "finds cards by type" do
          expect(run_query(type: "User")).to eq(user_cards)
        end

        it "handles casespace variants" do
          expect(run_query(type: "users")).to eq(user_cards)
        end

        it "handles relative names" do
          expect(run_query(type: "_self", context: "User")).to eq(user_cards)
        end

        it "treats Symbols as codenames" do
          search_search = run_query type: :search_type, limit: 1
          expect(Card[search_search.first].type_name).to eq(["Search"])
        end

        it "treats Integers as ids" do
          expect(run_query(type: Card::UserID)).to eq(user_cards)
        end

        it "handles subqueries" do
          expect(run_query(type: { name: "User" })).to eq(user_cards)
        end
      end

      describe "plus/part" do
        it "finds plus cards" do
          expect(run_query(plus: "A")).to eq(A_JOINEES)
        end

        it "finds connection cards" do
          expect(run_query(part: "A")).to eq(%w(A+B A+C A+D A+E C+A D+A F+A))
        end

        it "finds left connection cards" do
          expect(run_query(left: "A")).to eq(%w(A+B A+C A+D A+E))
        end

        it "finds right connection cards based on name" do
          expect(run_query(right: "A")).to eq(%w(C+A D+A F+A))
        end

        it "finds right connection cards based on content" do
          expect(run_query(right: { content: "Alpha [[Z]]" }, sort: :id))
            .to eq(%w(C+A D+A F+A))
        end
      end

      describe "relative plus/part" do
        it "cleans cql" do
          query = Card::Query.new(part: "_self", context: "A")
          expect(query.statement[:part]).to eq("A")
        end

        it "finds connection cards" do
          expect(run_query(part: "_self", context: "A"))
            .to eq(%w(A+B A+C A+D A+E C+A D+A F+A))
        end

        it "is able to use parts of nonexistent cards in search" do
          raise Card::Error, "B+A exists" if Card["B+A"]
          expect(run_query(left: "_right", right: "_left", context: "B+A"))
            .to eq(["A+B"])
        end

        it "finds plus cards for _self" do
          expect(run_query(plus: "_self", context: "A")).to eq(A_JOINEES)
        end

        it "finds plus cards for _left" do
          expect(run_query(plus: "_left", context: "A+B")).to eq(A_JOINEES)
        end

        it "finds plus cards for _right" do
          expect(run_query(plus: "_right", context: "C+A")).to eq(A_JOINEES)
        end
      end

      describe "created_by/creator_of" do
        before do
          Card.create name: "Create Test", content: "sufficiently distinctive"
        end

        it "finds Joe User as the card's creator" do
          expect(run_query(creator_of: "Create Test")).to eq(["Joe User"])
        end

        it "finds card created by Joe User" do
          expect(run_query(created_by: "Joe User", eq: "sufficiently distinctive"))
            .to eq(["Create Test"])
        end
      end

      describe "edited_by/editor_of" do
        it "finds card edited by joe using subquery" do
          expect(run_query(edited_by: { match: "Joe User" }))
            .to include("JoeLater", "JoeNow")
        end

        it "finds card edited by Decko Bot" do
          # this is a weak test, since it gives the name, but different sorting
          # mechanisms in other db setups
          # was having it return *account in some cases and 'A' in others
          expect(run_query(edited_by: "Decko Bot", name: "A")).to eq(%w(A))
        end

        it "fails gracefully if user isn't there" do
          expect(run_query(edited_by: "Joe LUser")).to eq([])
        end

        it "does not give duplicate results for multiple edits" do
          c = Card["JoeNow"]
          c.content = "testagagin"
          c.save
          c.content = "test3"
          c.save!
          expect(run_query(edited_by: "Joe User")).to include("JoeLater", "JoeNow")
        end

        it "finds joe user among card's editors" do
          expect(run_query(editor_of: "JoeLater")).to eq(["Joe User"])
        end
      end

      describe "last_edited_by/last_editor_of" do
        before do
          c = Card.fetch("A")
          c.content = "peculicious"
          c.save!
        end

        it "finds Joe User as the card's last editor" do
          expect(run_query(last_editor_of: "A")).to eq(["Joe User"])
        end

        it "finds card created by Joe User" do
          expect(run_query(last_edited_by: "Joe User", eq: "peculicious"))
            .to eq(["A"])
        end
      end

      describe "updated_by/updater_of" do
        it "finds card updated by Narcissist" do
          expect(run_query(updated_by: "Narcissist")).to eq(%w(Magnifier+lens))
        end

        it "finds Narcississt as the card's updater" do
          expect(run_query(updater_of: "Magnifier+lens")).to eq(%w(Narcissist))
        end

        it "does not give duplicate results for multiple updates" do
          expect(run_query(updater_of: "First")).to eq(["Decko Bot"])
        end

        it "does not give results if not updated" do
          expect(run_query(updater_of: "Sunglasses+price")).to be_empty
        end

        it "'or' doesn't mess up updated_by SQL" do
          expect(run_query(or: { updated_by: "Narcissist" }))
            .to eq(%w(Magnifier+lens))
        end

        it "'or' doesn't mess up updater_of SQL" do
          expect(run_query(or: { updater_of: "First" })).to eq(["Decko Bot"])
        end
      end
    end
  end
end
