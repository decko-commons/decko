RSpec.describe Card::Set::Self::InputType::Right::ContentOptions do
  let :options_rule_card do
    Card[:input_type, :right, :content_options]
  end

  it "loads the self set" do
    expect(options_rule_card.item_names)
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
