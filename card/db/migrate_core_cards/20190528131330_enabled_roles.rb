# -*- encoding : utf-8 -*-

class EnabledRoles < Card::Migration::Core
  def up
    ensure_trait "*enabled roles", "enabled_roles",
                 default: { type_id: Card::SessionID }

    Card.search type_id: Card::SessionID do |card|
      card.update_column :trash, true unless card.codename.present?
    end
  end
end
