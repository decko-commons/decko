require_relative "query_spec_helper"
RSpec.describe Card::Query::AbstractQuery do
  include QuerySpecHelper

  FASTEN_SQL = { join: /JOIN/, exist: /WHERE EXISTS/, in: /WHERE c\d\.id IN/ }.freeze

  each_fasten do |fastn|
    describe "fasten: #{fastn}" do
      let(:fasten) { fastn }

      it "contains the correct FASTEN_SQL" do
        sql = Card::Query.new(fasten: fasten, link_to: "A").sql
        expect(sql).to match FASTEN_SQL[fasten]
      end
    end
  end
end
