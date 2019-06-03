# -*- encoding : utf-8 -*-

describe Card::Set::All::Bar do
  specify "view bar" do
    expect_view(:bar).to have_tag("div.card-slot.bar-view")
  end

  specify "view bar_left" do
    expect_view(:bar_left).to have_tag("span.card-title")
  end

  xspecify "view bar_middle" do
    expect_view(:bar_middle).to have_tag("span.labeled-badge")
  end

  specify "view bar_bottom" do
    expect_view(:bar_bottom).to match(/Alpha/)
  end

  specify "view bar_nav" do
    expect_view(:bar_nav).to have_tag("div.bar-nav") do
      with_tag "a", href: /view=expanded_bar/
      with_tag "a", href: /view=collapsed_bar/
      with_tag "a.full-page-link"
      with_tag "a.edit-link"
    end
  end

  specify "view bar_expand_link" do
    expect_view(:bar_expand_link).to have_tag("a.slotter") do
      with_tag "i"
    end
  end

  specify "view bar_collapse_link" do
    expect_view(:bar_collapse_link).to have_tag("a.slotter") do
      with_tag "i"
    end
  end

  specify "view edit_button" do
    expect_view(:edit_button).to have_tag("a.btn")
  end
end
