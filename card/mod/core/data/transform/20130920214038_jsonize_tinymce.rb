# -*- encoding : utf-8 -*-

class JsonizeTinymce < Cardio::Migration::TransformMigration
  def up
    card = Card[:tiny_mce]
    cleaned_rows = card.db_content.strip.split(/\s*,\s+/).map do |row|
      key, val = row.split(/\s*:\s*/)
      val.gsub!(/"\s*\+\s*"/, "")
      val.gsub! "'", '",'
      %("#{key}":#{val})
    end
    card.content = %({\n#{cleaned_rows.join ",\n"}\n})
    card.save!
  end
end
