# -*- encoding : utf-8 -*-

describe Card::Set::Right::Structure do
  it "one_line_content is rendered as type + raw" do
    template = Card.new name: "A+*right+*structure",
                        content: "[[link]] {{nest}}"
    expect(template.format._render(:one_line_content)).to eq(
      '<a class="cardtype known-card" href="/RichText">RichText</a>' \
      " : [[link]] {{nest}}"
    )
  end

  it "one_line_content is rendered as type + raw" do
    template = Card.new name: "A+*right+*structure", type: "Html",
                        content: "[[link]] {{nest}}"
    expect(template.format._render(:one_line_content)).to eq(
      '<a class="cardtype known-card" href="/HTML">HTML</a> : [[link]] {{nest}}'
    )
  end

  # it 'renders core as raw' do
  #     trs = Card.fetch('*type+*right+*structure').format.render_core
  #     expect(trs).to eq '{"type":"_left"}'
  # end
end
