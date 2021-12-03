describe Card::Set::Self::InputOptions do
  it "loads the self set" do
    expect(Card[:input_type, :right, :content_options].item_names)
      .to contain_exactly(
        "ace editor",
        "autocomplete",
        "calendar",
        "checkbox",
        "filtered list",
        "list",
        "multiselect",
        "radio",
        "select",
        "tinymce editor",
        "text area",
        "text field"
      )
  end
end
