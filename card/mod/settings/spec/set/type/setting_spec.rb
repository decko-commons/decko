# -*- encoding : utf-8 -*-

describe Card::Set::Type::Setting do
  context "core view" do
    it "has a table" do
      core = render_card :core, name: :help
      assert_view_select core, "table"
    end
  end

  describe "rule_help view" do
    subject { Card[:read].format.render :rule_help }

    it "renders links (ie, not in template mode)" do
      is_expected.to have_tag(:div, class: "RIGHT-Xhelp content-view") do
        with_tag :a, class: "known-card", text: "Set"
      end
    end
  end
end
