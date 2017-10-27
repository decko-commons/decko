# -*- encoding : utf-8 -*-

class CorrectSignupSuccessMessage < Card::Migration::Core
  def up
    if (card = Card["signup success"]) && card.db_content.include?("{{*title}}")
      new_content = card.db_content.gsub "{{*title}}", "{{*title|core}}"
      card.update_attributes! content: new_content
    end
  end
end
