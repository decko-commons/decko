RSpec.describe Card::Set::Abstract::Search::Filter do
  subject do
    search_card = Card.new type: "Search"
    search_card.format.filter_form a: { input_field: "<input id='a'/>", label: "A" },
                                   b: { input_field: "<select id='b'/>", label: "B" },
                                   c: { input_field: "<select id='c'/>", label: "C",
                                        active: true }
  end

  specify "#filter_form" do
    is_expected.to have_tag "._filter-widget" do
      with_tag "div._filter-input-field-prototypes" do
        with_tag "div._filter-input-a" do
          with_tag "input#a"
        end
        with_tag "div._filter-input-b" do
          with_tag "select#b"
        end
        with_tag "div._filter-input-c" do
          with_tag "select#c"
        end
      end

      with_tag "div._filter-container"

      with_tag "div.dropdown._add-filter-dropdown" do
        with_tag "a.dropdown-item", with: { "data-category": "a" }
        with_tag "a.dropdown-item", with: { "data-category": "b" }
        with_tag "a.dropdown-item", with: { "data-category": "c", "data-active": "true" }
      end
    end
  end
end
