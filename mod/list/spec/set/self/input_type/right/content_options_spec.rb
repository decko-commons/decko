describe Card::Set::Self::InputType::Right::ContentOptions do
  it "loads the self set" do
    expect(Card[:input_type, :right, :content_options].item_names)
      .to contain_exactly(
        "ace editor",
        "autocomplete",
        "calendar",
        "checkbox",
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
