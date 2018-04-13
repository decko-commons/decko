# -*- encoding : utf-8 -*-

describe Card::Set::Type::Setting do
  context "core view" do
    it "has a table" do
      core = render_card :core, name: :help
      assert_view_select core, "table"
    end
  end

  describe "rule help view" do
    # it
  end
end
