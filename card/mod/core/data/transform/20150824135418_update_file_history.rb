# -*- encoding : utf-8 -*-

class UpdateFileHistory < Cardio::Migration::Transform
  def up
    Card.search(type: [:in, "file", "image"]).each { |card| update_actions card }
    Card.search(right: { codename: "machine_output" }).each(&:delete!)
  end

  def update_actions card
    card.actions.each do |action|
      next unless (content_change = action.change :db_content)
      next if content_change.new_record?

      update_change_value card, content_change
    end
  end

  def update_change_value card, content_change
    original_filename, file_type, action_id, mod = content_change.value.split("\n")
    return unless file_type.present? && action_id.present?

    extension = ::File.extname original_filename
    content_change.update! value: file_content_value(card, mod, action_id, extension)
  end

  def file_content_value card, mod, action_id, extension
    if mod.present?
      ":#{card.codename}/#{mod}#{extension}"
    else
      "~#{card.id}/#{action_id}#{extension}"
    end
  end
end
