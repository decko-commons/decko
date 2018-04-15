Self::Admin.add_to_basket(
  :tasks,
  name: :empty_trash,
  irreversible: true,
  execute_policy: -> { Card.empty_trash },
  stats: {
    title: "trashed cards",
    count: -> { Card.where(trash: true) },
    link_text: "empty trash",
    task: "empty_trash"
  }
)

module ClassMethods
  def empty_trash
    Card.delete_trashed_files
    Card.where(trash: true).delete_all
    Card::Action.delete_cardless
    Card::Change.delete_actionless
    Card::Reference.unmap_if_referee_missing
    Card::Reference.delete_if_referer_missing
  end

  # deletes any file not associated with a real card.
  def delete_trashed_files
    dir = Cardio.paths["files"].existent.first
    # TODO: handle cloud files
    return unless dir

    trashed_card_ids = all_trashed_card_ids
    file_ids = all_file_ids
    file_ids.each do |file_id|
      next unless trashed_card_ids.member?(file_id)
      if Card.exists?(file_id) # double check!
        raise Card::Error, "Narrowly averted deleting current file"
      end
      ::FileUtils.rm_rf "#{dir}/#{file_id}", secure: true
    end
  end

  def all_file_ids
    dir = Card.paths["files"].existent.first
    Dir.entries(dir)[2..-1].map(&:to_i)
  end

  def all_trashed_card_ids
    trashed_card_sql = %( select id from cards where trash is true )
    sql_results = Card.connection.select_all(trashed_card_sql)
    sql_results.map(&:values).flatten.map(&:to_i)
  end
end

def delete
  update_attributes trash: true unless new_card?
end

def delete!
  update_attributes! trash: true unless new_card?
end

event :manage_trash, :prepare_to_store, on: :create do
  pull_from_trash!
  self.trash = false
  true
end

def pull_from_trash!
  return unless (trashed_card = Card.find_by_key_and_trash key, true)
  # fwiw, now we _could_ get card using fetch look_in_trash: true (not tried).

  self.id = trashed_card.id
  # following is needed so that #id_in_database returns existing card id
  # (and record is updated correctly)
  db_attributes["id"] = trashed_card.db_attributes["id"]

  @from_trash = true
  @new_record = false
end

def db_attributes
  send(:mutations_from_database).send :attributes
end

event :validate_delete, :validate, on: :delete do
  unless codename.blank?
    errors.add :delete, "#{name} is is a system card. (#{codename})"
  end

  undeletable_all_rules_tags =
    %w[default style layout create read update delete]
  # FIXME: HACK! should be configured in the rule

  if junction? && left&.codename == :all &&
     undeletable_all_rules_tags.member?(right.codename.to_s)
    errors.add :delete, "#{name} is an indestructible rule"
  end

  if account && has_edits?
    errors.add :delete, "Edits have been made with #{name}'s user account.\n" \
                        "Deleting this card would mess up our history."
  end
end

event :validate_delete_children, after: :validate_delete, on: :delete do
  return if errors.any?
  children.each do |child|
    next unless child
    # prevents errors in cases where a child is deleted prior to this point
    # and thus is not returned by the fetch in #children

    child.trash = true
    add_subcard child
    # next if child.valid?
    # child.errors.each do |field, message|
    #   errors.add field, "can't delete #{child.name}: #{message}"
    # end
  end
end
