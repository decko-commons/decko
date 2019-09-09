# -*- encoding : utf-8 -*-

class InputType < Card::Migration::Core
  def up
    update_card :input, name: "*input type",
                        codename: "input_type",
                        update_referers: true
    update_card :options, name: "*content options",
                          codename: "content_options",
                          update_referers: true
    update_card :options_label, name: "*content option view",
                                codename: "content_option_view",
                                update_referers: true

    Card::Cache.reset_all

    ensure_card %i[all content_option_view], content: "label"
    Card.search right: :content_option_view, left: { not: :all } do |cov_rule|
      cov_rule.delete!
    end
  end
end
