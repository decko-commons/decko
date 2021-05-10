# -*- encoding : utf-8 -*-

describe Card::Content::Chunk, "Chunk" do
  context "Class" do
    it "populates prefix map on load" do
      expect(described_class.prefix_map_by_list[:default].keys.size)
        .to be_positive
      expect(described_class.prefix_map_by_list[:default]["{"][:class])
        .to eq(Card::Content::Chunk::Nest)
    end

    it "finds Chunk classes using matched prefix" do
      expect(described_class.find_class_by_prefix("{{"))
        .to eq(Card::Content::Chunk::Nest)
    end
  end
end
