# -*- encoding : utf-8 -*-

class CreateReferencesForSearchCards < Cardio::Migration::Transform
  def up
    Card.where(
      type_id: Card::SearchTypeID
    ).find_each.with_index do |card, index|
      card.update_references_out
      puts "completed #{index} search cards" if (index % 100).zero?
    end
  end
end
