# -*- encoding : utf-8 -*-

describe Card::Set::All::Csv do
  describe "csv view: row" do
    it "handles nests" do
      expect(card_subject.format(:csv).render_row).to eq(%w[A RichText])
    end
  end
end
