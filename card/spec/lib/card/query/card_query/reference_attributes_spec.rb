require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::ReferenceAttributes do
  include QuerySpecHelper

  each_fasten do |fastn|
    context "with fasten: #{fastn}" do
      let(:fasten) { fastn }

      describe "links" do
        it "handles refer_to" do
          @query = { refer_to: "Z" }
          is_expected.to eq(%w(A B))
        end

        it "handles link_to" do
          @query = { link_to: "Z" }
          is_expected.to eq(%w(A))
        end

        it "handles include" do
          @query = { include: "Z" }
          is_expected.to eq(%w(B))
        end

        it "handles linked_to_by" do
          @query = { linked_to_by: "A" }
          is_expected.to eq(%w(Z))
        end

        it "handles included_by" do
          @query = { included_by: "B" }
          is_expected.to eq(%w(Z))
        end

        it "handles referred_to_by" do
          @query = { referred_to_by: "X" }
          is_expected.to eq(%w(A A+B T))
        end
      end

      describe "compound relationships" do
        it "right_plus should handle subqueries" do
          @query = { right_plus: ["*create", refer_to: "Anyone"] }
          is_expected.to eq(["Fruit+*type", "Sign up+*type"])
        end

        it "plus should handle subqueries" do # albeit more slowly :)
          @query = { plus: ["*create", refer_to: "Anyone"] }
          is_expected.to eq(["Fruit+*type", "Sign up+*type"])
        end
      end

      describe "relative links" do
        it "handles relative refer_to" do
          @query = { refer_to: "_self", context: "Z" }
          is_expected.to eq(%w(A B))
        end
      end

      describe "member_of" do
        it "finds members" do
          @query = { member_of: "r1" }
          is_expected.to eq(%w(u1 u2 u3))
        end
      end

      describe "member" do
        it "finds roles" do
          @query = { member: { match: "u1" } }
          is_expected.to eq(%w(r1 r2 r3))
        end
      end
    end
  end
end