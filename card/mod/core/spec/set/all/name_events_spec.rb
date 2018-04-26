describe Card::Set::All::NameEvents do
  describe "event: set_name" do
    it "handles case variants" do
      c = Card.create! name: "chump"
      expect(c.name).to eq("chump")
      c.name = "Chump"
      c.save!
      expect(c.name).to eq("Chump")
    end

    context "changing from plus card to simple" do
      let (:card) { Card.create! name: "four+five" }

      before do
        card.update_attributes! name: "nine"
      end

      it "assigns the cardname" do
        expect(card.name).to eq("nine")
      end

      it "removes the left id" do
        expect(card.left_id).to eq(nil)
      end

      it "removes the right id" do
        expect(card.right_id).to eq(nil)
      end
    end
  end

  describe "event: set_left_and_right" do
    example "create junction" do
      expect do
        Card.create! name: "Peach+Pear", content: "juicy"
      end.to increase_card_count.by(3)
      expect(Card["Peach"]).to be_a(Card)
      expect(Card["Pear"]).to be_a(Card)
      expect(Card["Peach+Pear"]).to have_db_content "juicy"
    end
  end

  describe "event: autoname" do
    before do
      Card::Auth.as_bot do
        @b1 = Card.create! name: "Book+*type+*autoname", content: "b1"
      end
    end

    it "handles cards without names" do
      c = Card.create! type: "Book"
      expect(c.name).to eq("b1")
    end

    it "increments again if name already exists" do
      _b1 = Card.create! type: "Book"
      b2 = Card.create! type: "Book"
      expect(b2.name).to eq("b2")
    end

    it "handles trashed names" do
      b1 = Card.create! type: "Book"
      Card::Auth.as_bot { b1.delete }
      b1 = Card.create! type: "Book"
      expect(b1.name).to eq("b1")
    end
  end

  describe "event: escape_name" do
    it "escapes invalid characters" do
      c = Card.create! name: "8 / 5 <script>"
      expect(c.name).to eq("8 &#47; 5 &#60;script&#62;")
    end
  end

  describe "#validate_name" do
    it "does not allow empty name" do
      expect { create "" }
        .to raise_error(/Name can't be blank/)
    end

    it "does not allow mismatched name and key" do
      expect { create "Test", key: "foo" }
        .to raise_error(/wrong key/)
    end
  end

  describe "reset_codename_cache" do
    it "resets codename cache when codename is updated" do
      card = Card.create! name: "Codename Haver", codename: :codename_haver
      expect(Card::Codename.id(:codename_haver)).to eq(card.id)
    end
  end
end
