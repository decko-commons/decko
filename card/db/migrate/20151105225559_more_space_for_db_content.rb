class MoreSpaceForDbContent < ActiveRecord::Migration[4.2]
  def change
    change_column :cards, :db_content, :text, limit: 1.megabyte
    change_column :card_changes, :value, :text, limit: 1.megabyte
  end
end
