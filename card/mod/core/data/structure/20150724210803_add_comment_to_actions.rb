class AddCommentToActions < ActiveRecord::Migration[4.2]
  def up
    add_column :card_actions, :comment, :text
  end
end
