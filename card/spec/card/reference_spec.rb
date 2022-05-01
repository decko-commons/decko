# -*- encoding : utf-8 -*-

RSpec.describe Card::Reference, as_bot: true do
  describe "references on hard templated cards should get updated" do
    it "on structuree creation" do
      Card.create! name: "JoeForm", type: "UserForm"
      Card["JoeForm"].format.render!(:core)
      assert_equal ["joe_form+age", "joe_form+description", "joe_form+name"],
                   Card["JoeForm"].nestees.map(&:key).sort
    end

    it "on template creation" do
      create "SpecialForm", type: "Cardtype"
      create "Form1", type: "SpecialForm", content: "foo"
      create "SpecialForm+*type+*structure", content: "{{+bar}}"
      Card["Form1"].format.render!(:core)
      expect(Card["Form1"].nestees.map(&:key)).to eq(["form1+bar"])
    end

    it "on template update" do
      Card.create! name: "JoeForm", type: "UserForm"
      tmpl = Card["UserForm+*type+*structure"]
      tmpl.content = "{{+monkey}} {{+banana}} {{+fruit}}"
      tmpl.save!
      Card["JoeForm"].format.render!(:core)
      expect(Card["JoeForm"].nestees.map(&:key))
        .to contain_exactly("joe_form+banana", "joe_form+fruit", "joe_form+monkey")
    end
  end

  it "in references should survive cardtype change" do
    create! "Banana", "[[Yellow]]"
    create! "Submarine", "[[Yellow]]"
    create! "Sun", "[[Yellow]]"
    create! "Yellow"
    yellow_refs = Card["Yellow"].referers.map(&:name).sort
    expect(yellow_refs).to eq(%w[Banana Submarine Sun])

    y = Card["Yellow"]
    y.type_id = "UserForm".card_id
    y.save!

    yellow_refs = Card["Yellow"].referers.map(&:name).sort
    expect(yellow_refs).to eq(%w[Banana Submarine Sun])
  end

  it "container nest" do
    Card.create name: "bob+city"
    Card.create name: "address+*right+*default", content: "{{_L+city}}"
    Card.create name: "bob+address"
    expect(Card.fetch("bob+address").nestees.map(&:name)).to eq(["bob+city"])
    expect(Card.fetch("bob+city").nesters.map(&:name)).to eq(["bob+address"])
  end

  it "pickup new links on rename" do
    create! "L", "[[Ethan]]"  # no Ethan card yet...
    e = create! "Earthman"
    e.update! name: "Ethan" # NOW there is an Ethan card
    #  do we need the links to be caught before reloading the card?
    expect(Card["Ethan"].referers.map(&:name).include?("L")).not_to eq(nil)
  end

  it "updates references on rename when requested" do
    create! "watermelon", "mmmm"
    create! "watermelon+seeds", "black"
    lew = create!("Lew", "likes [[watermelon]] and [[watermelon+seeds|seeds]]")

    watermelon = Card["watermelon"]
    watermelon.name = "grapefruit"
    watermelon.save!
    result = "likes [[grapefruit]] and [[grapefruit+seeds|seeds]]"
    expect(lew.reload.content).to eq(result)
  end

  it "updates referers on rename when requested (case 2)" do
    card = Card["admin field 1", :right, :read]
    old_refs = described_class.where(referee_id: Card::AdministratorID)

    card.name = ["admin field 1", :self, :read].cardname
    card.save!

    new_refs = described_class.where(referee_id: Card::AdministratorID)
    expect(old_refs).to eq(new_refs)
  end

  it "does not update references when not requested" do
    watermelon = create "watermelon", "mmmm"
    watermelon_seeds = create "watermelon+seeds", "black"
    lew = create("Lew", "likes [[watermelon]] and [[watermelon+seeds|seeds]]")

    assert_equal [watermelon.id, watermelon_seeds.id],
                 lew.references_out.order(:id).map(&:referee_id),
                 "stores referee ids"

    watermelon = Card["watermelon"]
    watermelon.skip = :update_referer_content
    watermelon.name = "grapefruit"
    watermelon.save!

    correct_content = "likes [[watermelon]] and [[watermelon+seeds|seeds]]"
    expect(lew.reload.content).to eq(correct_content)

    ref_types = lew.references_out.order(:id).map(&:ref_type)
    expect(ref_types).to eq(%w[L L P]) # , "need partial references!"
    actual_referee_ids = lew.references_out.order(:id).map(&:referee_id)
    assert_equal actual_referee_ids, [nil, nil, "seed".card_id],
                 'only partial reference to "seeds" should have referee_id'
  end

  context "when renaming junction cards" do
    let(:x) { Card["X"] } # links to A+B

    def rename updating_referers=true
      args = { name: "Peanut+Butter" }
      args[:skip] = :update_referer_content unless updating_referers

      Card["A+B"].update! args
    end

    it "updating referers can be opted into" do
      rename
      expect(x.content).to eq("[[A]] [[Peanut+Butter]] [[T]]")
    end

    it "updating referers can be opted out of" do
      rename false
      expect(x.content).to eq("[[A]] [[A+B]] [[T]]")
    end
  end

  it "template nest" do
    Card.create! name: "ColorType", type: "Cardtype", content: ""
    Card.create! name: "ColorType+*type+*structure", content: "{{+rgb}}"
    green = Card.create! name: "green", type: "ColorType"
    create! "rgb"
    green_rgb = Card.create! name: "green+rgb", content: "#00ff00"

    expect(green.reload.nestees.map(&:name)).to eq(["green+rgb"])
    expect(green_rgb.reload.nesters.map(&:name)).to eq(["green"])
  end

  def expect_reference referee, referer, content
    Card.create name: referee
    Card.create name: referer, content: content
    expect(Card[referee].referers.map(&:name)).to eq([referer])
    expect(Card[referer].referees.map(&:name)).to eq([referee])
  end

  it "simple link" do
    expect_reference "alpha", "beta", "I link to [[alpha]]"
  end

  it "link with spaces" do
    expect_reference "alpha card", "beta card", "I link to [[alpha card]]"
  end

  it "simple nest" do
    expect_reference "alpha", "beta", "I nest [[alpha]]"
  end

  it "non simple link" do
    expect_reference "alpha", "beta", "I link to [[alpha|ALPHA]]"
  end

  it "query" do
    Card.create(
      type: "Search",
      name: "search with references",
      content: '{"name":"X", "right_plus":["Y",{"content":["in","A","B"]}]}'
    )
    y_referers = Card["Y"].referers.map(&:name)
    expect(y_referers).to include("search with references")

    search_referees = Card["search with references"].referees.map(&:name).sort
    expect(search_referees).to eq(%w[A B X Y])
  end

  it "handles contextual names in Basic cards" do
    create_basic "basic w refs", "{{_+A}}"
    Card["A"].update! name: "AAA"
    expect(Card["basic w refs"].content).to eq "{{_+AAA}}"
  end

  it "handles contextual names in Search cards" do
    create_search_type "search w refs", '{"name":"_+A"}'
    Card["A"].update! name: "AAA"
    expect(Card["search w refs"].content).to eq '{"name":"_+AAA"}'
  end

  it "handles commented nest" do
    c = create "nest comment test", "{{## hi mom }}"
    expect(c.errors).to be_empty
  end

  it "pickup new links on create" do
    create! "woof", "[[Lewdog]]"  # no Lewdog card yet...
    e = create! "Lewdog"          # now there is
    # NOTE e.referers does not work, you have to reload
    expect(e.reload.referers.map(&:name).include?("woof")).not_to eq(nil)
  end

  it "pickup new nests on create" do
    Card.create! name: "woof", content: "{{Lewdog}}"
    # no Lewdog card yet...
    e = Card.new name: "Lewdog", content: "grrr"
    # now it's inititated
    expect(e.name_referers.map(&:name).include?("woof")).not_to eq(nil)
  end
end
