# -*- encoding : utf-8 -*-

class FixCompoundSelfSets < Cardio::Migration::Transform
  def up
    Card.where("codename is not null and name is null").each do |card|
      card.include_set_modules
      card.update_column :codename, nil
      next unless card.respond_to? :attachment

      card.update_column :db_content, card.attachment.db_content
    end
  end
end
