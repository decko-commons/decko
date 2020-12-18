# -*- encoding : utf-8 -*-

class ChangeBootstrapCardTypeToScss < Cardio::Migration::Core
  def up
    create_or_update! name: "*machine cache", codename: "machine_cache"
    if (card = Card[:bootstrap_cards])
      card.update! type_id: Card::ScssID
    end
  end
end
