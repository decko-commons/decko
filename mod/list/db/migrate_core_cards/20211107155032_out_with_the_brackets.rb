# -*- encoding : utf-8 -*-

# delete brackets from card content
class OutWithTheBrackets < Cardio::Migration
  def up
    list_type_ids = %i[pointer list].map(&:card_id)
    ["[[", "]]"].each do |brackets|
      Card.where(type_id: list_type_ids).in_batches.update_all(
        "db_content = REPLACE(db_content, '#{brackets}', '')"
      )
    end
  end
end
