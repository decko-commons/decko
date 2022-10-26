# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Item do
  def card_subject
    "stacks".card
  end

  specify "#item_keys" do
    expect(card_subject.item_keys).to eq %w[horizontal vertical]
  end

  specify "#item_ids" do
    expect(card_subject.item_ids).to include(a_kind_of(Integer))
  end

  specify "#first_card" do
    expect(card_subject.first_card).to eq "horizontal".card
  end

  specify "#first_name" do
    expect(card_subject.first_name).to eq "horizontal"
  end

  specify "#first_id" do
    expect(card_subject.first_id).to eq "horizontal".card_id
  end

  specify "#first_code" do
    card_subject.content = "*account"
    expect(card_subject.first_code).to eq :account
  end

  specify "view: :count" do
    expect_view(:count).to eq(2)
  end

  specify "html format: #item_links" do
    expect(format_subject.item_links.join).to have_tag("a", href: "horizontal")
  end

  describe "#item_names" do
    subject do
      item_names_args = @context ? { context: @context } : {}
      Card.new(@args).item_names(item_names_args)
    end

    it "returns item for each line of basic content" do
      @args = { name: "foo", content: "X\nY" }
      is_expected.to eq(%w[X Y])
    end

    it "returns list of card names for search" do
      @args = { name: "foo", type: "Search", content: '{"name":"Z"}' }
      is_expected.to eq(["Z"])
    end

    it "handles searches relative to context card" do
      # NOTE: A refers to 'Z'
      @context = "A"
      @args = { name: "foo", type: "Search",
                content: '{"referred_to_by":"_self"}' }
      is_expected.to eq(["Z"])
    end
  end

  describe "item_cards" do
    it "handles :complete arg " do
      expect(card_subject.item_cards(complete: "vert")).to eq ["vertical".card]
    end
  end
end
