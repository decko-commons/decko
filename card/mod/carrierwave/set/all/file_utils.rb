module ClassMethods
  def update_all_storage_locations
    Card.search(type_id: ["in", Card::FileID, Card::ImageID])
        .each(&:update_storage_location!)
  end

  def delete_tmp_files_of_cached_uploads
    cards_with_disposable_attachments do |card, action|
      card.delete_files_for_action action
      action.delete
    end
  end

  def cards_with_disposable_attachments
    draft_actions_with_attachment.each do |action|
      # we don't want to delete uploads in progress
      next unless old_enough?(action.created_at) && (card = action.card)
      # we can't delete attachments we don't have write access to
      next if card.read_only?

      yield card, action
    end
  end

  def old_enough? time, expiration_time=5.day.to_i
    Time.now - time > expiration_time
  end

  def draft_actions_with_attachment
    Card::Action.find_by_sql(
      "SELECT * FROM card_actions "\
        "INNER JOIN cards ON card_actions.card_id = cards.id "\
        "WHERE cards.type_id IN (#{Card::FileID}, #{Card::ImageID}) "\
        "AND card_actions.draft = true"
    )
  end

  def count_cards_with_attachment
    Card.search type_id: ["in", Card::FileID, Card::ImageID], return: :count
  end
end
