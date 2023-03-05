# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Html do
  before do
    Card::Auth.signin Card::WagnBotID
  end

  it "has special editor" do
    assert_view_select render_input("Html"), 'textarea[rows="5"]'
  end

  it "renders no html tags in one_line_content view" do
    a = "A".card
    a.assign_attributes type: :html, content: "<strong>Lions and Tigers</strong>"
    rendered = a.format.render :one_line_content
    expect(rendered.strip).to eq "Lions and Tigers"
  end

  it "renders nests" do
    rendered = render_card :core, type: "HTML", content: "{{a}}"
    expect(rendered).to match(/slot/)
  end

  it "does not render uris" do
    rendered = render_card :core, type: "HTML", content: "http://google.com"
    expect(rendered).not_to match(/<a/)
  end
end
