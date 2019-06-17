# -*- encoding : utf-8 -*-
require "card/content/chunk"

RSpec.describe Card::Env do
  describe "slot_opts" do
    it "allows only shark keys" do
      with_params slot: { bogus: "block", title: "captain" } do
        described_class.slot_opts == { title: "captain" }
      end
    end
  end
end
