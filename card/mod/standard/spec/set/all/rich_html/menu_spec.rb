# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::Menu do
  it "can change menu link to 'edit_in_place'" do
    expect(render_content("{{B|open; edit:content_inline}}"))
      .to have_tag :a, with: { href: "/A?view=edit_in_place" }
  end
end
