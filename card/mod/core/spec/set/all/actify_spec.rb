# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Actify do
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

  describe "Card.create!" do
    it "does not prevent validations when run as subcard" do
      with_test_events do
        test_event :finalize do
          expect { Card.create! name: "A" }.to raise_error(/unique/)
          raise Card::Error, "woot"
        end
        expect { Card["B"].update! content: "what" }.to raise_error(/woot/)
      end
    end
  end
end
