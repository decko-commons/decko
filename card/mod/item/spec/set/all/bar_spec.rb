# -*- encoding : utf-8 -*-

describe Card::Set::All::Bar do
  specify "view mini_bar" do
    expect_view(:mini_bar).to have_tag("div.card-slot.bar-view")
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

  specify "view bar_page_link" do
    expect_view(:bar_page_link).to have_tag("a.text-muted") do
      with_tag "i"
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
