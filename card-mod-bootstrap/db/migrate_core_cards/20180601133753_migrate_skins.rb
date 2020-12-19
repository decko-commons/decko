# -*- encoding : utf-8 -*-

class MigrateSkins < Cardio::Migration::Core
  def up
    Card.search(link_to: "bootstrap default skin", type_id: Card::SkinID) do |card|
      card.drop_item! "bootstrap default skin"
      card.update! type_id: Card::CustomizedBootswatchSkinID
    end
  end
end
