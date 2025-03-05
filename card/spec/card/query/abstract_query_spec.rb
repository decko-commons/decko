require_relative "query_spec_helper"
RSpec.describe Card::Query::AbstractQuery do
  include QuerySpecHelper

  let(:fasten_sql) do
    { join: /JOIN/, exist: /WHERE EXISTS/, in: /WHERE c\d\.id IN/ }.freeze
  end

  each_fasten do |fastn|
    describe "fasten: #{fastn}" do
      let(:fasten) { fastn }

      it "contains the correct FASTEN_SQL" do
        sql = Card::Query.new(fasten: fasten, link_to: "A").sql
        expect(sql).to match fasten_sql[fasten]
      end
    end
  end
end
