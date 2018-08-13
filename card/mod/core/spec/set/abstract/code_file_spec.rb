# -*- encoding : utf-8 -*-

describe Card::Set::Abstract::CodeFile do
  specify "view bar_middle" do
    expect_view(:bar_middle).to have_tag("i.fa")
    expect_view(:bar_middle).to have_tag("span.text-muted")
  end
end
