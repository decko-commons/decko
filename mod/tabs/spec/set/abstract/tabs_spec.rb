RSpec.describe Card::Set::Abstract::Tabs do
  check_views_for_errors

  # sample module with methods commonly overridden in set mods with Abstract::Tabs
  module TmpTabTest
    def tab_list
      %i[refers_to nonsense]
    end

    def tab_options
      {
        refers_to: { view: :name, count: 5 },
        nonsense: { view: :link, count: 6 }
      }
    end
  end

  describe "view: tabs" do
    it "respects #tab_list and #tab_options" do
      fmt = format_subject
      fmt.singleton_class.include TmpTabTest
      expect(fmt.render_tabs).to have_tag("div.tabbable") do
        with_tag("div.tab-pane") { "A" }
      end
    end
  end
end
