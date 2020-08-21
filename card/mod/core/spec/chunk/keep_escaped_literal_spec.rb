# -*- encoding : utf-8 -*-

RSpec.describe Card::Content::Chunk::KeepEscapedLiteral do
  context "when parsing syntax" do
    def apply_chunk content
      Card::Content.new(content, Card.new, chunk_list: :references_keep_escaping).to_s
    end

    it "duplicates backslashes before nests" do
      expect(apply_chunk('\{{A}}')).to eq('\\\\{{A}}')
    end

    it "duplicates backslacses before links" do
      expect(apply_chunk('\[[A]]')).to eq('\\\\[[A]]')
    end

    it "doesn't duplicate random backslashes " do
      expect(apply_chunk('\ \[A]')).to eq('\ \[A]')
    end
  end
end
