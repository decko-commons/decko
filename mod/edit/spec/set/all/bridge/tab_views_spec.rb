# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Bridge::TabViews do
  check_views_for_errors

  specify "view :related_tab" do
    expect_view(:related_tab).to have_tag :ul do
      with_tag "li.nav-item" do
        with_tag "a.nav-link[href*=children]", "children"
      end
    end
  end
end
