# -*- encoding : utf-8 -*-

describe Card::Set::Self::AdminInfo do
  # SPECSTUB
  specify "view core" do
    expect_view(:core).to have_tag("div.alert.alert-warning.alert-dismissible") do
      with_tag "button.close"
      with_tag "a.external-link"
    end
  end
end
