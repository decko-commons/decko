# -*- encoding : utf-8 -*-

class EnabledRoles < Cardio::Migration::Transform
  def up
    Card.search type_id: Card::SessionID do |card|
      card.update_column :trash, true unless card.codename.present?
    end
  end
end
