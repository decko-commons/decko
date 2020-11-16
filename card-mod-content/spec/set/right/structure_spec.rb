# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Structure do
  it "one_line_content is rendered as type + raw" do
    template = Card.new name: "A+*right+*structure",
                        content: "[[link]] {{nest}}"
    expect(template.format._render(:one_line_content))
      .to have_tag "div.text-muted.one-line" do
        with_tag "a.cardtype.known-card", with: { href: "/Nest_list" }, text: "Nest list"
        with_text(/ \: \[\[link\]\] \{\{nest\}\}/)
      end
  end

  it "one_line_content is rendered as type + raw" do
    template = Card.new name: "A+*right+*structure", type: "Html",
                        content: "[[link]] {{nest}}"
    expect(template.format._render(:one_line_content))
      .to have_tag "div.text-muted.one-line" do
      with_tag "a.cardtype.known-card", with: { href: "/HTML" }, text: "HTML"
      with_text(/ \: \[\[link\]\] \{\{nest\}\}/)
    end
  end

  # it 'renders core as raw' do
  #     trs = Card.fetch('*type+*right+*structure').format.render_core
  #     expect(trs).to eq '{"type":"_left"}'
  # end
end
