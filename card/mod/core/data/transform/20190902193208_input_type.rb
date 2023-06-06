# -*- encoding : utf-8 -*-

class InputType < Cardio::Migration::Transform
  def up
    update_card! :input, name: "*input type", codename: "input_type"
    update_card! :options, name: "*content options", codename: "content_options"
    update_card! :options_label, name: "*content option view",
                                 codename: "content_option_view"

    Card::Cache.reset_all

    Card.ensure name: %i[all content_option_view], content: "smart_label"
    Card.search right: :content_option_view, left: { not: :all }, &:delete!
  end
end
