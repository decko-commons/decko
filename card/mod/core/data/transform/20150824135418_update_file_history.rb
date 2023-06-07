# -*- encoding : utf-8 -*-

class UpdateFileHistory < Cardio::Migration::Transform
  def up
    Card.search(type: [:in, "file", "image"]).each do |card|
      card.actions.each do |action|
        next unless (content_change = action.change :db_content)
        next if content_change.new_record?

        original_filename, file_type, action_id, mod = content_change.value.split("\n")
        next unless file_type.present? && action_id.present?

        value =
          if mod.present?
            ":#{card.codename}/#{mod}#{::File.extname(original_filename)}"
          else
            "~#{card.id}/#{action_id}#{::File.extname(original_filename)}"
          end
        content_change.update! value: value
      end
    end
    Card.search(right: { codename: "machine_output" }).each(&:delete!)
  end
end
