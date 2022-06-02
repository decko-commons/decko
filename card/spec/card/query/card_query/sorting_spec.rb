require_relative "../query_spec_helper"
RSpec.describe Card::Query::CardQuery::Sorting do
  include QuerySpecHelper

  # it "sorts by create" do
  #   Card.create! name: "classic bootstrap skin head"
  #   # classic skin head is created more recently than classic skin,
  #   # which is in the seed data
  #   expect(run_query(sort_by: "create", name: [:match, "classic bootstrap skin"]))
  #     .to eq(["classic bootstrap skin", "classic bootstrap skin head"])
  # end

  it "sorts by name" do
    expect(run_query(name: %w[in B Z A Y C X], sort_by: "name", dir: "desc"))
      .to eq(%w[Z Y X C B A])
  end

  it "sorts by content" do
    expect(run_query(name: %w[in Z T A], sort_by: "content")).to eq(%w[A Z T])
  end

  it "plays nice with match" do
    expect(run_query(match: "two", not: { match: "42" }).sort)
      .to eq(cards_matching_two.sort - ["42"])
  end

  # it "sorts by plus card content" do
  #   Card::Auth.as_bot do
  #     Card["Setting+*self+*table of contents"].update! content: 10
  #     Card.create! name: "RichText+*type+*table of contents", content: "3"
  #     expect(run_query(right_plus: "*table of contents",
  #                      sort_by: { right: "*table_of_contents" },
  #                      sort_as: "integer"))
  #       .to eq(%w[*all RichText+*type Setting+*self])
  #   end
  # end

  it "sorts by count", as_bot: true do
    expect(run_query(name: [:in, "*always", "*never", "*edited"],
                     sort_by: { right: "*follow", item: "referred_to", return: "count" }))
      .to eq(["*never", "*edited", "*always"])
  end

  #  it 'sorts by update' do
  #    # do this on a restricted set so it won't change every time we
  #    #  add a card..
  #    Card::Query.run(
  #    match: 'two', sort_by: 'update', dir: 'desc'
  #    ).map(&:name).should == ['One+Two+Three', 'One+Two','Two','Joe User']
  #    Card['Two'].update! content: 'new bar'
  #    Card::Query.run(
  #    match: 'two', sort_by: 'update', dir: 'desc'
  #    ).map(&:name).should == ['Two','One+Two+Three', 'One+Two','Joe User']
  #  end
end
