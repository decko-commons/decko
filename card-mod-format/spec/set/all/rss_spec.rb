# -*- encoding : utf-8 -*-

describe Card::Set::All::Rss do
  it "renders recent.rss" do
    with_rss_enabled do
      rendered = Card[:recent].format(:rss).show(nil, {})
      expect(rendered).to match(/xml/)
    end
  end

  it "handles bad queries" do
    bad_search = Card.create! name: "Bad Search",
                              type: "Search", content: '{"found_by":"home"}'
    rendered = bad_search.format(:rss).render_feed_body
    expect(rendered).to have_tag("item", text: /Card::Error::BadQuery/)
  end
end
