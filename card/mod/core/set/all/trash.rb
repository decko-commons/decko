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
    Card.where(trash: true).in_batches.update_all(left_id: nil, right_id: nil)
    Card.where(trash: true).in_batches.delete_all
    Card::Action.delete_cardless
    Card::Change.delete_actionless
    Card::Act.delete_actionless
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
      raise Card::Error, tr(:exception_almost_deleted) if Card.exists?(file_id)
      ::FileUtils.rm_rf "#{dir}/#{file_id}", secure: true
    end
  end

  def all_file_ids
    dir = Cardio.paths["files"].existent.first
    Dir.entries(dir)[2..-1].map(&:to_i)
  end

  def all_trashed_card_ids
    trashed_card_sql = %( select id from cards where trash is true )
    sql_results = Card.connection.select_all(trashed_card_sql)
    sql_results.map(&:values).flatten.map(&:to_i)
  end
end

def delete args={}
  add_to_trash args do |delete_args|
    update delete_args
  end
end

def delete! args={}
  add_to_trash args do |delete_args|
    update! delete_args
  end
end

def add_to_trash args
  return if new_card?
  yield args.merge trash: true
end

event :manage_trash, :prepare_to_store, on: :create do
  pull_from_trash!
  self.trash = false
  true
end

def pull_from_trash!
  return unless (id = Card::Lexicon.id key) # name is already known
  return unless (trashed_card = Card.where(id: id).take)&.trash
  # confirm name is actually in trash

  db_attributes["id"] = trashed_card.db_attributes["id"]
  # id_in_database returns existing card id

  @from_trash = true
  @new_record = false
end

def db_attributes
  send(:mutations_from_database).send :attributes
end

event :validate_delete, :validate, on: :delete do
  unless codename.blank?
    errors.add :delete, tr(:error_system_card, name: name, codename: codename)
  end

  undeletable_all_rules_tags =
    %w[default style layout create read update delete]
  # FIXME: HACK! should be configured in the rule

  if junction? && left&.codename == :all &&
     undeletable_all_rules_tags.member?(right.codename.to_s)
    errors.add :delete, tr(:error_indestructible, name: name)
  end

  errors.add :delete, tr(:error_user_edits, name: name) if account && has_edits?
end

event :validate_delete_children, after: :validate_delete, on: :delete do
  return if errors.any?
  each_child do |child|
    next unless child
    # prevents errors in cases where a child is deleted prior to this point
    # and thus is not returned by the fetch in #children

    delete_as_subcard child
    # next if child.valid?
    # child.errors.each do |field, message|
    #   errors.add field, "can't delete #{child.name}: #{message}"
    # end
  end
end

def delete_as_subcard subcard
  subcard.trash = true
  add_subcard subcard
end
