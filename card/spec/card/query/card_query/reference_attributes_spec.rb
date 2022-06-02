require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::ReferenceAttributes do
  include QuerySpecHelper

  each_fasten do |fastn|
    context "with fasten: #{fastn}" do
      let(:fasten) { fastn }

      describe "links" do
        it "handles refer_to" do
          expect(run_query(refer_to: "Z")).to eq(%w[A B])
        end

        it "handles link_to" do
          expect(run_query(link_to: "Z")).to eq(%w[A])
        end

        it "handles include" do
          expect(run_query(include: "Z")).to eq(%w[B])
        end

        it "handles linked_to_by" do
          expect(run_query(linked_to_by: "A")).to eq(%w[Z])
        end

        it "handles included_by" do
          expect(run_query(included_by: "B")).to eq(%w[Z])
        end

        it "handles referred_to_by" do
          expect(run_query(referred_to_by: "X").sort).to eq(%w[A A+B T])
        end
      end

      describe "compound relationships" do
        it "right_plus should handle subqueries" do
          expect(run_query(right_plus: ["*create", { refer_to: "Anyone" }], sort_by: :id))
            .to eq(["Sign up+*type", "Fruit+*type"])
        end

        it "plus should handle subqueries" do # albeit more slowly :)
          expect(run_query(plus: ["*create", { refer_to: "Anyone" }], sort_by: :id))
            .to eq(["Sign up+*type", "Fruit+*type"])
        end
      end

      describe "relative links" do
        it "handles relative refer_to" do
          expect(run_query(refer_to: "_self", context: "Z")).to eq(%w[A B])
        end
      end

      describe "member_of" do
        it "finds members" do
          expect(run_query(member_of: "r1")).to eq(%w[u1 u2 u3])
        end
      end

      describe "member" do
        it "finds roles" do
          expect(run_query(member: { match: "u1" })).to eq(%w[r1 r2 r3])
        end
      end
    end
  end
end
