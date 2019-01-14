# -*- encoding : utf-8 -*-

class ChangeBootstrapCardTypeToScss < Card::Migration::Core
  def up
    create_or_update name: "*machine cache", codename: "machine_cache"
    if (card = Card[:bootstrap_cards])
      card.update_attributes! type_id: Card::ScssID
    end
  end
end
