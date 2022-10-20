# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::AdminInfo do
  # FIXME: there is no :admin_info card.  Either add it or get rid of this set.
  def card_subject
    "A".card.with_set described_class
  end

  specify "view core" do
    expect_view(:core).to have_tag("div.alert.alert-warning.alert-dismissible") do
      with_tag "button.btn-close"
    end
  end
end
