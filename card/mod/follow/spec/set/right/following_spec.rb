# -*- encoding : utf-8 -*-

describe Card::Set::Right::Following do
  context "when admin is following" do
    def card_subject
      Card.fetch "Joe Admin", :following
    end

    check_views_for_errors :core, :status, :rule_editor
  end
end
