# -*- encoding : utf-8 -*-

class InputType < Cardio::Migration::Transform
  def up
    Card::Cache.reset_all

    Card.ensure name: %i[all content_option_view], content: "smart_label"
    Card.search right: :content_option_view, left: { not: :all }, &:delete!
  end
end
