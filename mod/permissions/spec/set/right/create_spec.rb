# -*- encoding : utf-8 -*-

describe Card::Set::Right::Create do
  it "renders the perm editor" do
    Card::Auth.as_bot do
      card = Card.new name: "A+B+*self+*create"
      assert_view_select card.format._render_input, "div[class=perm-editor]"
    end
  end
end
