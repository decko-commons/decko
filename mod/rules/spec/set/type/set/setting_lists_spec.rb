# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Set::SettingLists do
  def card_subject
    Card.fetch("User+*type")
  end

  specify "#nest_editor_field_related_settings", as_bot: true do
    create ["characters", :right, :input_type], content: "select"
    create ["characters", :right, :default], type_id: Card::ListID
    card = Card.new name: "RichText+characters+*type plus right"
    expect(card.format(:html).nest_editor_field_related_settings)
      .to eq %i[default help input_type content_options content_option_view]
  end

  check_views_for_errors
end
