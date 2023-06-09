# -*- encoding : utf-8 -*-

class JsonizeTinymce < Cardio::Migration::Transform
  def up
    card = Card[:tiny_mce]
    content = card.db_content
    return if valid_json? content

    card.content = cleaned_content content
    card.save!
  end

  def cleaned_content content
    cleaned_rows = content.strip.split(/\s*,\s+/).map do |row|
      key, val = row.split(/\s*:\s*/)
      val.gsub!(/"\s*\+\s*"/, "")
      val.gsub! "'", '",'
      %("#{key}":#{val})
    end
    %({\n#{cleaned_rows.join ",\n"}\n})
  end

  def valid_json? text
    JSON.parse text
  rescue JSON::ParserError
    false
  end
end
