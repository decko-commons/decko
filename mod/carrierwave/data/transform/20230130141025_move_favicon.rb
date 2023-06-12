class MoveFavicon < Cardio::Migration::Transform
  def up
    card = Card[:favicon]
    return unless card.db_content == ":favicon/standard.png"

    card.update_column :db_content, ":favicon/carrierwave.png"
  end
end
