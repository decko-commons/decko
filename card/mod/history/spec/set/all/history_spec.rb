# -*- encoding : utf-8 -*-

describe Card::Set::All::History do
  # SPECSTUB
  specify "view history" do
    expect_view(:history).to have_tag("div.card-slot.history-view") do
      with_tag "div.card-body"
      with_tag "div.card-header"
    end
  end
end
