# -*- encoding : utf-8 -*-

describe Card::Set::Abstract::Search do
  specify "view no_search_results" do
    expect_view(:no_search_results).to have_tag("div.search-no-results")
  end
end
