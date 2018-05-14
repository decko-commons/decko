# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Virtual do
  VIRTUAL_CONTENT = "vc"
  let(:card) do
    double("virtual card", junction?: true,
           generate_virtual_content: VIRTUAL_CONTENT,
           left_id: 1, right_id: 5)
  end

  let(:create_virtual) {described_class.create(card)}

  describe ".create" do
    it "has count 10" do
      expect(create_virtual.content).to eq "vc"
    end
  end

  describe ".fetch_value" do
    context "existing entry" do
      it "returns virtual content" do
        create_count
        expect(described_class.fetch_value(card)).to eq VIRTUAL_CONTENT
      end
    end

    context "new entry" do
      it "returns 10" do
        expect(described_class.fetch_value(card)).to eq VIRTUAL_CONTENT
      end
    end
  end

  describe ".refresh" do
    it "returns 15" do
      expect(described_class.fetch_value(card)).to eq VIRTUAL_CONTENT
      allow(card).to receive(:generate_virtual_content).and_return "changed"
      described_class.refresh card
      expect(described_class.fetch_value(card)).to eq "changed"
    end
  end
end
