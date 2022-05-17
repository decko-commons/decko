
class RemoveCustomizedBootswatchSkins < Cardio::Migration::Core
  def up
    convert_bootswatch_skins
    delete_code_card :customized_bootswatch_skin
  end

  def convert_bootswatch_skins
    parent_field_name = Card[:parent].name

    Card.search(type_id: ::Card::CustomizedBootswatchSkinID) do |card|
      update_args = { type_id: Card::BootswatchSkinID }
      parent = find_parent(card.name)
      if parent && parent.id != card.id
        update_args[:subcards] = { "+#{parent_field_name}" => { content: parent.name } }
      end
      card.update! update_args
      card.field(:variables)&.update content: ""
    end
    Card::Cache.reset_all
  end

  def find_parent card_name
    potential_parent_name = card_name.downcase.sub("customized", "").gsub(/\d/,"").strip
    Card[potential_parent_name]
  end
end
