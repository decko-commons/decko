class MoveFavicon < Cardio::Migration::Transform
  def up
    card = Card[:favicon]
    if card.db_content == ":favicon/standard.png"
      card.update_column :db_content, ":favicon/carrierwave.png"
    end
  end
end
