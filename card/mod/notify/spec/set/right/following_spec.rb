# -*- encoding : utf-8 -*-

describe Card::Set::Right::Following do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  context "when admin is following" do
    let(:following) { Card.fetch "Joe Admin", :following }

    describe_views :core, :status, :rule_editor do
      it "doesn't have errors" do
        expect(following.format.render(view)).to lack_errors
      end
    end
  end
end
