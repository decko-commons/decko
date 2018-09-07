# -*- encoding : utf-8 -*-

describe Card::Set::All::Tabs do
  specify "view tabs" do
    expect_view(:tabs).to have_tag("div.tabbable") do
      with_tag "ul.nav"
      with_tag "li.nav-item"
      with_tag "div.tab-content"
    end
  end

  specify "view pills" do
    expect_view(:pills).to have_tag("div.tabbable") do
      with_tag "ul.nav"
      with_tag "li.nav-item"
      with_tag "div.tab-content"
    end
  end
end
