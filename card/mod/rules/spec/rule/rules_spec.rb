# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Rule do
  def card_subject
    Card.fetch("*read+*right+*input", new: {})
  end

  check_html_views_for_errors

  it "renders setting view for a right set" do
    r = Card["*read+*right"].format.render_open
    expect(r).not_to match(/error/i)
    expect(r).not_to match("No Card!")
    # warn "r = #{r}"
    assert_view_select r, 'table[class="set-rules table"]' do
      assert_select 'a[href~="/*read+*right+*read?view=open_rule"]',
                    text: "read"
    end
  end

  it "renders setting view for a *input rule", as_bot: true do
    r = Card.fetch("*read+*right+*input", new: {}).format.render_open_rule
    expect(r).to have_tag "table" do

    end
  end
end
