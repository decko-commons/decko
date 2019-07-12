# -*- encoding : utf-8 -*-

# FIXME: - this seems like a LOT of testing but it doesn't cover a ton of ground
# I think we should move the rendering tests into basic and trim this to about
# a quarter of its current length

RSpec.describe Card do
  RSpec::Matchers.define :have_toc do
    match do |card|
      values_match?(/Table of Contents/, card.format.render_open_content)
    end
  end

  let(:c1) { described_class["Onne Heading"] }
  let(:c2) { described_class["Twwo Heading"] }
  let(:c3) { described_class["Three Heading"] }
  let(:rule_card) { c1.rule_card(:table_of_contents) }

  context "when there is a general toc rule of 2" do
    before do
      Card::Auth.as_bot do
        create [:basic, :type, :table_of_contents], "2"
      end
    end

    specify do
      expect(c1.type_id).to eq(Card::BasicID)
      expect(rule_card).to be_a Card
    end

    describe ".rule" do
      it "has a value of 2" do
        expect(rule_card.content).to eq("2")
        expect(c1.rule(:table_of_contents)).to eq("2")
      end
    end

    describe "renders with/without toc" do
      it "does not render for 'Onne Heading'" do
        expect(c1).not_to have_toc
      end
      it "renders for 'Twwo Heading'" do
        expect(c2).to have_toc
      end
      it "renders for 'Three Heading'" do
        expect(c3).to have_toc
      end
    end

    describe ".related_sets" do
      it "has 1 set (right) for a simple card" do
        sets = described_class["A"].related_sets.map { |s| s[0] }
        expect(sets).to eq(["A+*right"])
      end
      it "has 2 sets (type, and right) for a cardtype card" do
        sets = described_class["Cardtype A"].related_sets.map { |s| s[0] }
        expect(sets).to eq(["Cardtype A+*type", "Cardtype A+*right"])
      end
      # it "shows type plus right sets when they exist" do
      #   Card::Auth.as_bot do
      #     Card.create name: 'RichText+A+*type plus right', content: ''
      #   end
      #   sets = Card['A'].related_sets
      #   sets.should == ['A+*self', 'A+*right', 'RichText+A+*type plus right']
      # end
      # it "shows type plus right sets when they exist, and type" do
      #   Card::Auth.as_bot do
      #     Card.create name: 'RichText+Cardtype A+*type plus right', content: ''
      #   end
      #   sets = Card['Cardtype A'].related_sets
      #   sets.should == ['Cardtype A+*self', 'Cardtype A+*type',
      #     'Cardtype A+*right', 'RichText+Cardtype A+*type plus right']
      # end
      it "is empty for a non-simple card" do
        sets = described_class["A+B"].related_sets.map { |s| s[0] }
        expect(sets).to eq([])
      end
    end
    #     # class methods
    #     describe ".default_rule" do
    #       it 'has default rule' do
    #         Card.default_rule(:table_of_contents).should == '0'
    #       end
    #     end
  end

  context "when I change the general toc setting to 1" do
    before do
      rule_card.content = "1"
    end

    describe ".rule" do
      it "has a value of 1" do
        expect(c1.rule(:table_of_contents)).to eq("1")
      end
    end

    describe "renders with/without toc" do
      it "does not render toc for 'Onne Heading'" do
        expect(c1).to have_toc
      end
      it "renders toc for 'Twwo Heading'" do
        expect(c2).to have_toc
      end
      it "does not render for 'Twwo Heading' when changed to 3" do
        rule_card.content = "3"
        expect(c2.rule(:table_of_contents)).to eq("3")
        expect(c2).not_to have_toc
      end
    end
  end

  context "when I use CardtypeE cards" do
    before do
      Card::Auth.as_bot do
        @c1 = described_class.create name: "toc1", type: "CardtypeE",
                                     content: described_class["Onne Heading"].content
        @c2 = described_class.create name: "toc2", type: "CardtypeE",
                                     content: described_class["Twwo Heading"].content
        @c3 = described_class.create name: "toc3", type: "CardtypeE",
                                     content: described_class["Three Heading"].content
      end
      expect(@c1.type_name).to eq("Cardtype E")
      @rule_card = @c1.rule_card(:table_of_contents)

      expect(@c1).to be
      expect(@c2).to be
      expect(@c3).to be
      expect(@rule_card).to be
    end

    describe ".rule" do
      it "has a value of 0" do
        expect(@c1.rule(:table_of_contents)).to eq("0")
        expect(@rule_card.content).to eq("0")
      end
    end

    describe "renders without toc" do
      it "does not render for 'Onne Heading'" do
        expect(@c1).not_to have_toc
      end
      it "renders for 'Twwo Heading'" do
        expect(@c2).not_to have_toc
      end
      it "renders for 'Three Heading'" do
        expect(@c3).not_to have_toc
      end
    end

    describe ".rule_card" do
      it "doesn't have a type rule" do
        expect(@rule_card).to be
        expect(@rule_card.name).to eq("*all+*table of contents")
      end

      it "get the same card without the * and singular" do
        expect(@c1.rule_card(:table_of_contents)).to eq(@rule_card)
      end
    end

    #     # class methods
    #     describe ".default_rule" do
    #       it 'has default rule' do
    #         Card.default_rule(:table_of_contents).should == '0'
    #       end
    #     end
  end

  context "when I create a new rule" do
    before do
      Card::Auth.as_bot do
        described_class.create! name: "RichText+*type+*table of contents", content: "2"
        @c1 = described_class.create! name: "toc1", type: "CardtypeE",
                                      content: described_class["Onne Heading"].content
        @c2 = described_class.create! name: "toc2", content: described_class["Twwo Heading"].content
        @c3 = described_class.create! name: "toc3", content: described_class["Three Heading"].content
        expect(@c1.type_name).to eq("Cardtype E")
        @rule_card = @c1.rule_card(:table_of_contents)

        expect(@c1).to be
        expect(@c2).to be
        expect(@c3).to be
        expect(@rule_card.name).to eq("*all+*table of contents")
        if (c = described_class["CardtypeE+*type+*table of content"])
          c.content = "2"
          c.save!
        else
          described_class.create! name: "CardtypeE+*type+*table of content", content: "2"
        end
      end
    end
    it "takes on new setting value" do
      c = described_class["toc1"]
      expect(c.rule_card(:table_of_contents).name)
        .to eq("CardtypeE+*type+*table of content")
      expect(c.rule(:table_of_contents)).to eq("2")
    end

    describe "renders with/without toc" do
      it "does not render for 'Onne Heading'" do
        expect(@c1).not_to have_toc
      end
      it "renders for 'Twwo Heading'" do
        expect(@c2.rule(:table_of_contents)).to eq("2")
        expect(@c2).to have_toc
      end
      it "renders for 'Three Heading'" do
        expect(@c3).to have_toc
      end
    end
  end

  context "when I change the general toc setting to 1" do
    let(:c1) { described_class["Onne Heading"] }
    let(:c2) { described_class["Twwo Heading"] }
    let(:rule_card) { c1.rule_card(:table_of_contents) }

    before do
      rule_card.content = "1"
    end

    describe ".rule" do
      it "has a value of 1" do
        expect(rule_card.content).to eq("1")
        expect(c1.rule(:table_of_contents)).to eq("1")
      end
    end

    describe "renders with/without toc" do
      it "does not render toc for 'Onne Heading'" do
        expect(c1).to have_toc
      end
      it "renders toc for 'Twwo Heading'" do
        expect(c2).to have_toc
      end
      it "does not render for 'Twwo Heading' when changed to 3" do
        rule_card.content = "3"
        expect(c2).not_to have_toc
      end
    end
  end
end
