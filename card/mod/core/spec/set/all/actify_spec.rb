# -*- encoding : utf-8 -*-

RSpec.describe "act API" do
  describe "#act" do
    let(:card) { Card["A"] }

    before do
      allow(card).to receive(:act).and_return nil
    end

    it "is called by valid?" do
      card.valid?
      expect(card).to have_received :act
    end

    it "is called by #save!" do
      card.save!
      expect(card).to have_received :act
    end

    it "is called by #save" do
      card.save
      expect(card).to have_received :act
    end

    it "is called by #update" do
      card.update content: "A"
      expect(card).to have_received :act
    end

    it "is called by #update!" do
      card.update! content: "A"
      expect(card).to have_received :act
    end

    it "is called by #update_attributes" do
      card.update_attributes content: "A"
      expect(card).to have_received :act
    end

    it "is called by #update_attributes!" do
      card.update_attributes! content: "A"
      expect(card).to have_received :act
    end
  end
end
