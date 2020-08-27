# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::AdminInfo do
  specify "view core" do
    pending "Recaptcha is ? should this be in the recaptcha mod?"
    expect_view(:core).to have_tag("div.alert.alert-warning.alert-dismissible") do
      with_tag "button.close"
    end
  end
end
