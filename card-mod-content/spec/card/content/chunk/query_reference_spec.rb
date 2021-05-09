# -*- encoding : utf-8 -*-

describe Card::Content::Chunk::QueryReference do
  context "syntax parsing" do
    subject { query_refs.first.name }

    before do
      @class = described_class
    end

    let :query_refs do
      Card::Content.new(@content, Card.new(type: "Search")).find_chunks(:QueryReference)
    end

    it "handles simple search" do
      @content = '{"name":"Waldo"}'
      expect(subject).to eq "Waldo"
    end

    it "handles operators" do
      @content = '{"name":["eq","Waldo"]}'
      expect(subject).to eq "Waldo"
    end

    it "handles multiple values for operators" do
      @content = '{"name":["in","Where","Waldo"]}'
      expect(query_refs[1].name).to eq "Waldo"
    end

    it "handles plus attributes" do
      @content = '{"right_plus":["Waldo",{"content":"here"}]}'
      expect(subject).to eq "Waldo"
    end

    it "handles nested query structures" do
      @content = '{"any":{"content":"Where", ' \
                 '"right_plus":["was",{"name":"Waldo"}]}}'
      expect(query_refs[0].name).to eq "Where"
      expect(query_refs[1].name).to eq "was"
      expect(query_refs[2].name).to eq "Waldo"
    end

    it "handles contextual names" do
      @content = '{"name":"_+Waldo"}'
      expect(subject).to eq "_+Waldo"
    end
  end
end
