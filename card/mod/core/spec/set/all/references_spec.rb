# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::References do
  it "replaces references should work on nests inside links" do
    card = Card.create! name: "ref test", content: "[[test_card|test{{test}}]]"
    assert_equal "[[test_card|test{{best}}]]",
                 card.replace_reference_syntax("test", "best")
  end

  describe "#referers" do
    it "returns all cards that refer to card" do
      expect(Card["Blue"].referers.map(&:name))
        .to contain_exactly(
          "blue includer 1", "blue includer 2", "blue linker 1", "blue linker 2"
        )
    end
  end

  describe "#nesters" do
    it "returns all cards that nest card" do
      expect(Card["Blue"].nesters.map(&:name))
        .to contain_exactly("blue includer 1", "blue includer 2")
    end
  end

  describe "#referee" do
    it "returns all cards that card nests" do
      expect(Card["Y"].referees.map(&:name)).to contain_exactly("A", "A+B", "B", "T")
    end

    it "returns all cards that card links to and their ancestors" do
      # NOTE: B is not directly referred to; the reference is implied by the link to A+B
      expect(Card["X"].referees.map(&:name)).to contain_exactly("A", "A+B", "B", "T")
    end
  end

  describe "#nestee" do
    it "returns all cards that card nests" do
      expect(Card["Y"].nestees.map(&:name)).to contain_exactly("A", "A+B", "B", "T")
    end

    it "returns all cards that card links to" do
      expect(Card["X"].nestees.map(&:name)).to eq([])
    end
  end

  describe "event :update_referer_content" do
    it "handles self references" do
      c = Card["A"]
      c.update_attributes! content: "[[A]]"
      c.refresh.update_attributes! name: "AAA", update_referers: true
      expect(c.refresh.content).to eq("[[AAA]]")
    end
  end
end
