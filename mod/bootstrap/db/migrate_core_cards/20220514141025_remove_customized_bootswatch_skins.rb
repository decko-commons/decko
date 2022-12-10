
class RemoveCustomizedBootswatchSkins < Cardio::Migration::Core
  def up
    return unless Card::Codename[:customized_bootswatch_skin]

    convert_bootswatch_skins
    delete_code_card :customized_bootswatch_skin
  end

  def convert_bootswatch_skins
    parent_field_name = :parent.cardname
    Card.search(type_id: ::Card::CustomizedBootswatchSkinID) do |card|
      begin
      update_args = { type_id: Card::BootswatchSkinID, skip: :asset_input_changed }
      parent = find_parent(card.name)
      if parent && parent.id != card.id
        update_args[:subcards] = { "+#{parent_field_name}" => { content: parent.name } }
      end
      #delete_empty_stylesheets card
      card.field(:variables)&.update content: ""
      card.update! update_args
      # rescue => e
      #   binding.pry
      end

    end
    Card::Cache.reset_all
  end

  # def delete_empty_stylesheets card
  #   s = card.fetch :stylesheets
  #   binding.pry
  #   return unless s&.item_names.present?
  #
  #   s.update! content: (s.item_cards.map { |c| c.name if c.real? }.compact)
  # end

  def find_parent card_name
    potential_parent_name = card_name.downcase.sub("customized", "").gsub(/\d/, "").strip
    Card[potential_parent_name]
  end
end
