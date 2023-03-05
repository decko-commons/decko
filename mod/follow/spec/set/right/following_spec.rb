# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Following do
  context "when admin is following" do
    def card_subject
      Card.fetch "Joe Admin", :following
    end

    check_views_for_errors
  end
end
