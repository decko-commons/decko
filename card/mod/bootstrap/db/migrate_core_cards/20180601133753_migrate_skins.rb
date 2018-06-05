# -*- encoding : utf-8 -*-

class MigrateSkins < Card::Migration::Core
  def up
    Card.search(link_to: "bootstrap default skin", type_id: Card::SkinID) do |card|
      card.drop_item! "bootstrap default skin"
      card.update_attributes! type_id: Card::CustomizedBootswatchSkinID
    end
  end
end
