describe Card::Set::All::Filter do
  subject do
    Card["A"].format.filter_form a: { input_field: "<input id='a'/>", label: "A" },
                                 b: { input_field: "<select id='b'/>", label: "B" },
                                 c: { input_field: "<select id='c'/>", label: "C",
                                      active: true }
  end

  specify "#filter_form" do
    is_expected.to have_tag "form._filter_form" do
      with_tag "div._filter_input_field_prototypes" do
        with_tag "div._filter_input_field.a" do
          with_tag "input#a"
        end
        with_tag "div._filter_input_field.b" do
          with_tag "select#b"
        end
        with_tag "div._filter_input_field.c" do
          with_tag "select#c"
        end
      end

      with_tag "div._filter_container" do
        with_tag "div.input-group" do
          with_tag "span._selected_category", text: /C/
          with_tag "select#c"
        end
      end

      with_tag "div.btn-group._add_filter_dropdown" do
        with_tag "a.dropdown-item", with: { "data-category" => "a" }
        with_tag "a.dropdown-item", with: { "data-category" => "b" }
        with_tag "a.dropdown-item.d-none", with: { "data-category" => "c" }
      end
    end
  end
end
