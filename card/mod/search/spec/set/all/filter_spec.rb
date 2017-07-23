describe Card::Set::All::Filter do
  subject do
    Card["A"].format.filter_form a: { input_field: "<input class='a'/>", label: "A" },
                                 b: { input_field: "<select class='b'/>", label: "B" }
  end
  specify "#filter_form" do
    is_expected.to have_tag "form._search_form" do
      with_tag "input.a"
      with_tag "select.b"
      with_tag "div.btn-group._add_filter_dropdown" do
        with_tag "a.dropdown-tiem", with: { data: { category: "a" } }
      end
    end
  end
end