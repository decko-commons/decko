# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::PlainText do
  it "has special editor" do
    assert_view_select render_editor("Plain Text"), 'textarea[rows="5"]'
  end

  it "has special content that escapes HTML" do
    expect(render_card(:core, type: "Plain Text", content: "<b></b>"))
      .to eq "&lt;b&gt;&lt;/b&gt;"
  end

  specify "view core" do
    expect_view(:core).to have_tag("a.known-card") do
      with_tag "span.card-title"
    end
  end

  specify "view one_line_content" do
    rendered = format_subject.render :one_line_content
                           #type: "Plain Text",
                           #content: "<strong>Lions and Tigers</strong>"
    expect(rendered).to have_tag "div.text-muted", /Alpha/
  end
end
