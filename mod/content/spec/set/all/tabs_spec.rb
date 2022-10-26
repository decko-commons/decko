RSpec.describe Card::Set::All::Tabs do
  describe "tabs view" do
    it "renders tab panel" do
      tabs = render_card :tabs, content: "[[A]]\n[[B]]\n[[C]]", type: "pointer"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select "li > a[data-bs-toggle=tab]"
      end
    end

    it "loads only the first tab pane" do
      tabs = render_card :tabs, content: "[[A]]\n[[B]]\n[[C]]", type: "pointer"
      expect(tabs).to have_tag :div, with: { role: "tabpanel" } do
        with_tag "div.tab-pane#tab-tempo_rary-1-a" do
          with_tag "div.card-slot#a-content-view"
        end
        with_tag :li do
          with_tag "a.load",
                   with: { "data-bs-toggle": "tab", href: "#tab-tempo_rary-2-b" }
        end
        with_tag "div.tab-pane#tab-tempo_rary-2-b"
      end
    end

    it "handles relative names" do
      Card::Auth.as_bot do
        Card.create! name: "G", content: "[[+B]]", type: "pointer",
                     subcards: { "+B" => "GammaBeta" }
      end
      tabs = Card.fetch("G").format.render_tabs
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select "div.tab-pane#tab-g-1-g-b .d0-card-content", "GammaBeta"
      end
    end

    it "handles item views" do
      tabs = render_content "{{Fruit+*type+*create|tabs|name}}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select "div.tab-pane#tab-fruit-Xtype-Xcreate-1-anyone", "Anyone"
      end
    end

    it "handles item params" do
      tabs = render_content "{{Fruit+*type+*create|tabs|name;structure:Home}}"
      params = { slot: { structure: "Home" }, view: :name }.to_param
      path = "/Anyone?#{params}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select %(li > a[data-bs-toggle="tab"][data-url="#{path}"])
      end
    end

    it "handles contextual titles" do
      create name: "tabs card", type: "pointer",
             content: "[[A+B]]\n[[One+Two+Three]]\n[[Four+One+Five]]"
      tabs = render_content  "{{tabs card|tabs|closed;title:_left}}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select 'li > a[data-bs-toggle="tab"]', "A"
        assert_select 'li > a[data-bs-toggle="tab"]', "One+Two"
      end
    end

    it "handles contextual titles as link" do
      create name: "tabs card",
             content: "[[A+B]]\n[[One+Two+Three]]\n[[Four+One+Five]]",
             type: "pointer"
      tabs = render_content "{{tabs card|tabs|closed;title:_left;show:title_link}}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select 'li > a[data-bs-toggle="tab"]', "A"
        assert_select 'li > a[data-bs-toggle="tab"]', "One+Two"
      end
    end

    it "handles nests as items" do
      tabs = render_card :tabs, name: "tab_test", type: :plain_text,
                                content: "{{A|type;title:my tab title}}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select 'li > a[data-bs-toggle=tab][href="#tab-tab_test-1-a"]',
                      "my tab title"
        assert_select "div.tab-pane#tab-tab_test-1-a", "RichText"
      end
    end

    it "works with search cards" do
      Card.create name: "Asearch",
                  type: "Search",
                  content: '{"type":"User","sort_by":"name"}'
      tabs = render_content("{{Asearch|tabs|name}}")
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select(
          'li > a[data-bs-toggle=tab][href="#tab-asearch-2-joe_admin"] span.card-title',
          "Joe Admin"
        )
      end
    end
  end
end
