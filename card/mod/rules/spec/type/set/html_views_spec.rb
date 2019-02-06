# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Set::HtmlViews do
  def card_subject
    Card.fetch("User+*type")
  end

  check_html_views_for_errors

  it "renders setting view for a right set" do
    r = Card["*read+*right"].format.render_open
    # warn "r = #{r}"
    assert_view_select r, 'table[class="set-rules table"]' do
      assert_select 'a[href~="/*read+*right+*read?view=open_rule"]',
                    text: "read"
    end
  end
end
