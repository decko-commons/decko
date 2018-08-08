# -*- encoding : utf-8 -*-

describe Card::Set::All::ActionView do
  # SPECSTUB
  specify "view action_summary" do
    expect_view(:action_summary).to have_tag("div.card-slot") do
      with_tag "ins"
    end
  end
end
