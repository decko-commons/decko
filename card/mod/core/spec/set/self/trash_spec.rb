# -*- encoding : utf-8 -*-

describe Card::Set::Self::Trash do
  specify "view core" do
    expect_view(:core).to have_tag("table")
  end
end
