describe Card::Set::Self::InputOptions do
  it "loads the self set" do
    expect(Card[:input_type, :right, :content_options].item_names).to contain_exactly(
      "radio", "checkbox", "select", "multiselect", "list", "ace editor", "filtered list",
      "prosemirror editor", "tinymce editor", "text area", "text field", "calendar"
    )
  end
end
