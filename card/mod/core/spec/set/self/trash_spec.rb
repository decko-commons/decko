# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Trash do
  # FIXME: there is no :trash card.  Either add it or get rid of this set.
  def card_subject
    "A".card.with_set described_class
  end

  specify "view core" do
    expect_view(:core).to have_tag("table")
  end
end
