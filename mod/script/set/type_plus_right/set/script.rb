include_set Abstract::AssetOutputter, output_format: :js

def ok_item_types
  %i[java_script coffee_script list]
end

format :html do
  view :remote_script_tags do
    card.item_cards.map do |mod|
      remote_script_tags mod
    end.compact
  end

  def remote_script_tags card
    tags = card.format(:html).render :remote_script_tags
    return unless tags.present?

    %(<!-- #{card.name.left} (remote) -->\n#{tags})
  end
end
