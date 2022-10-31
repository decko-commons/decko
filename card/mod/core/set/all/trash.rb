basket[:tasks][:empty_trash] = {
  mod: :core,
  irreversible: true,
  execute_policy: -> { Cardio::Utils.empty_trash }
}

def trash?
  trash
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

event :manage_trash, :prepare_to_store, on: :create do
  pull_from_trash!
  self.trash = false
  true
end

event :validate_delete, :validate, on: :delete do
  unless codename.blank?
    errors.add :delete, t(:core_error_system_card, name: name, codename: codename)
  end

  undeletable_all_rules_tags =
    %w[default style layout create read update delete]
  # FIXME: HACK! should be configured in the rule

  if compound? && left&.codename == :all &&
     undeletable_all_rules_tags.member?(right.codename.to_s)
    errors.add :delete, t(:core_error_indestructible, name: name)
  end

  errors.add :delete, t(:core_error_user_edits, name: name) if account && has_edits?
end

event :delete_children, after: :validate_delete, on: :delete do
  return if errors.any?

  each_child do |child|
    child.include_set_modules
    delete_as_subcard child
    # next if child.valid?
    # child.errors.each do |field, message|
    #   errors.add field, "can't delete #{child.name}: #{message}"
    # end
  end
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

def add_to_trash args
  yield args.merge(trash: true) unless new_card?
end

def db_attributes
  send(:mutations_from_database).send :attributes
end

def delete_as_subcard subcard
  subcard.trash = true
  subcard subcard
end
