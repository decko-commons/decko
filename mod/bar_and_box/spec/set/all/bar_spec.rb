# -*- encoding : utf-8 -*-

describe Card::Set::All::Bar do
  specify "view bar" do
    expect_view(:bar).to have_tag("div.card-slot.bar-view")
  end

  specify "view bar_left" do
    expect_view(:bar_left).to have_tag("span.card-title")
  end

  specify "view bar_bottom" do
    expect_view(:bar_bottom).to match(/Alpha/)
  end

  specify "view bar_menu" do
    expect_view(:bar_menu).to have_tag("div.bar-menu") do
      with_tag "a.edit-link"
      with_tag "a.full-page-link"
      with_tag "a.bridge-link"
    end
  end

  specify "view edit_button" do
    expect_view(:edit_button).to have_tag("a.btn")
  end
end
