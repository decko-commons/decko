# -*- encoding : utf-8 -*-

class CardtypeGrouping < Cardio::Migration::Core
  CONTENT =
    <<~EOT
            {{+description|content}}
      #{'      '}
            {{_|add_button}} {{_|configure_button}}
      #{'      '}
            {{_|grouped_list}}
    EOT

  def up
    ensure_card %i[cardtype self structure], content: CONTENT
  end
end
