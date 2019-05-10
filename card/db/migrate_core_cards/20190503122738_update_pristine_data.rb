# -*- encoding : utf-8 -*-

class UpdatePristineData < Card::Migration::Core
  HEADER = <<-HTML.strip_heredoc

  HTML



  def up
    update "*header", content: HEADER

    names = %w[
      home home+original
      *footer *credit *sidebar
      *title
      *all+*layout
      home+*self+*layout
      default_layout home_layout
      full_width_layout
      ]
    names.select { |n| !Card.exists?(n) || Card.fetch(n)&.pristine? }
    merge_cards names
  end
end
