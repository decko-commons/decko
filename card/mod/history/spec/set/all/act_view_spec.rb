# -*- encoding : utf-8 -*-

describe Card::Set::All::ActView do
  # SPECSTUB
  specify "view act" do
    expect_view(:act).to have_tag("div.card") do
      with_tag "div.card-header"
      with_tag "div.card-body"
    end
  end

  specify "view act_legend" do
    expect_view(:act_legend).to have_tag("div.row") do
      with_tag "div"
    end
  end
end
