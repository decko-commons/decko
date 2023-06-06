class AddCommentToActions < Cardio::Migration::Schema
  def up
    add_column :card_actions, :comment, :text
  end
end
