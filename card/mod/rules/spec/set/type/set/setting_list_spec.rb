# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Set::HtmlViews do
  def card_subject
    Card.fetch("User+*type")
  end

  describe "#nest_editor_field_related_settings" do
    example "list with input type select", as_bot: true do
      create ["characters", :right, :input_type], content: "select"
      create ["characters", :right, :default], type_id: Card::ListID
      card = Card.new name:"RichText+characters+*type plus right"
      expect(card.format(:html).nest_editor_field_related_settings)
        .to eq %i[default help input_type content_options content_option_view]
    end

    example "list with input type ", as_bot: true do
      create ["characters", :right, :input_type], content: "select"
      create ["characters", :right, :default], type_id: Card::ListID
      card = Card.new name:"RichText+characters+*type plus right"
      expect(card.format(:html).nest_editor_field_related_settings)
        .to eq %i[default help input_type content_options content_option_view]
    end
  end


  check_html_views_for_errors
end
