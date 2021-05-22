# -*- encoding : utf-8 -*-

describe Card::Set::All::Templating do
  describe "#structurees" do
    it "for User+*type+*structure should return all Users" do
      Card::Auth.as_bot do
        c = Card.create name: "User+*type+*structure"
        users

        expect(c.structuree_names.sort).to eq(
          ["Big Brother", "Joe Admin", "Joe Camel", "Joe User", "John",
           "Narcissist", "No Count", "Optic fan", "Sample User", "Sara",
           "Sunglasses fan", "u1", "u2", "u3"]
        )
      end
    end
  end

  describe "with right structure" do
    before do
      Card::Auth.as_bot do
        @bt = Card.create! name: "birthday+*right+*structure",
                           type: "Date",
                           content: "Today!"
      end
      @jb = Card.create! name: "Jim+birthday"
    end

    it "has default content" do
      expect(@jb.format._render_raw).to eq("Today!")
    end

    it "changes type and content with template" do
      Card::Auth.as_bot do
        @bt.content = "Tomorrow"
        @bt.type = "Phrase"
        @bt.save!
      end
      jb = @jb.refresh true
      expect(jb.format.render!(:raw)).to eq("Tomorrow")
      expect(jb.type_id).to eq(Card::PhraseID)
    end

    it "has type and content overridden by (new) type_plus_right set" do
      Card::Auth.as_bot do
        create_plain_text "RichText+birthday+*type plus right+*structure", "Yesterday"
      end
      jb = @jb.refresh true
      expect(jb.content).to eq("Yesterday")
      expect(jb.type_id).to eq(Card::PlainTextID)
    end
  end

  describe "with right default" do
    before do
      Card::Auth.as_bot do
        @bt = Card.create! name: "birthday+*right+*default",
                           type: "Date",
                           content: "Today!"
      end
      @bb = Card.new name: "Bob+birthday"
      @jb = Card.create! name: "Jim+birthday"
    end

    it "has default cardtype" do
      expect(@jb.type_code).to eq(:date)
    end

    it "has default content" do
      expect(Card["Jim+birthday"].content).to eq("Today!")
    end

    it "applies to new cards" do
      pb = Card.new name: "Pete+birthday"
      expect(pb.content).to eq("Today!")
      expect(pb.content).to eq("Today!")
    end
  end

  describe "with type structure" do
    before do
      Card::Auth.as_bot do
        @dt = create_basic "Date+*type+*structure", "Tomorrow"
      end
    end

    it "returns templated content even if content is passed in" do
      new_date_card = Card.new type: "Date", content: ""
      expect(new_date_card.format._render(:raw)).to eq("Tomorrow")
    end

    describe "and right structure" do
      before do
        Card::Auth.as_bot do
          Card.create name: "Jim+birthday", content: "Yesterday"
          @bt = Card.create! name: "birthday+*right+*structure",
                             type: "Date",
                             content: "Today"
        end
      end

      it "*right setting should override *type setting" do
        expect(Card["Jim+birthday"].content).to eq("Today")
      end

      it "defers to normal content " \
         "when *structure rule's content is (exactly) '_self'" do
        Card::Auth.as_bot do
          Card.create! name: "Jim+birthday+*self+*structure", content: "_self"
        end
        expect(Card["Jim+birthday"].content).to eq("Yesterday")
      end
    end
  end
end
