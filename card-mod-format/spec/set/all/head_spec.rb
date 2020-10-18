# -*- encoding : utf-8 -*-

describe Card::Set::All::Head do
  specify "view head" do
    expect_view(:head).to have_tag("title"), "A - WikiRate"
    expect_view(:head).to have_tag("link")
    expect_view(:head).to have_tag("script")
  end

  specify "view meta_tags" do
    expect_view(:meta_tags).to have_tag("meta")
  end

  specify "view page_title_tag" do
    expect_view(:page_title_tag).to have_tag("title")
  end

  specify "view favicon_tag" do
    expect_view(:favicon_tag).to have_tag("link")
  end

  specify "view universal_edit_button" do
    expect_view(:universal_edit_button).to have_tag("link")
  end

  specify "view head_stylesheet" do
    expect_view(:head_stylesheet).to have_tag("link")
  end

  specify "view decko_script_variables" do
    expect_view(:decko_script_variables).to have_tag("script")
  end
end
