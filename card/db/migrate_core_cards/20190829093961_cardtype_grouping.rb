# -*- encoding : utf-8 -*-

class CardtypeGrouping < Cardio::Migration::Core
  CONTENT =
    <<~STRUCTURE
      {{+description|content}}

      {{_|add_button}} {{_|configure_button}}
      
      {{_|grouped_list}}
    STRUCTURE

  def up
    ensure_card %i[cardtype self structure], content: CONTENT
  end
end
