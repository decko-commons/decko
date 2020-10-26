# -*- encoding : utf-8 -*-

describe Card::Set::Type::Uri do
  it "has special editor" do
    assert_view_select render_input("Uri"),
                       'input[type="text"][class~="d0-card-content"]'
  end

  it "renders core view links" do
    card = Card.create(type: "URI", name: "A URI card",
                       content: "https://decko.org/Home")
    assert_view_select(
      card.format.render!("core"),
      'a[class="external-link"][href="https://decko.org/Home"]'
    ) do
      assert_select 'span[class="card-title"]', text: "A URI card"
    end
  end

  it "renders core view links with title arg" do
    card = Card.create(type: "URI", name: "A URI card",
                       content: "https://decko.org/Home")

    assert_view_select(
      card.format.render!("core", title: "My Title"),
      'a[class="external-link"][href="https://decko.org/Home"]'
    ) do
      assert_select 'span[class="card-title"]', text: "My Title"
    end
  end

  it "renders title view in a plain formatter" do
    card = Card["A"]
    expect(card.format(:text).render!("title", title: "My Title"))
      .to eq "My Title"
    expect(card.format(:text).render!("title")).to eq "A"
  end

  it "renders url_link for regular cards" do
    card = Card["A"]
    expect(card.format(:text).render!("url_link")).to eq "/A"
    assert_view_select card.format.render!("url_link"),
                       'a[class="internal-link"][href="/A"]',
                       text: "/A"
  end

  it "renders a url_link view" do
    card = Card.create(type: "URI", name: "A URI card",
                       content: "https://decko.org/Home")
    assert_view_select card.format.render!("url_link"),
                       'a[class="external-link"]',
                       text: "https://decko.org/Home"
    expect(card.format(:text).render!("url_link")).to eq "https://decko.org/Home"
  end
end
