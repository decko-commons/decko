event :validate_permission_to_assign_roles, :validate, on: :save do
  return unless (fr = forbidden_roles).present?

  errors.add :permission_denied,
             "You don't have permission to assign the role#{'s' if fr.size > 1} "\
             "#{fr.map(&:name).to_sentence}"   # LOCALIZE
end

def forbidden_roles
  # restore old roles for permission check
  with_old_role_permissions do |new_roles|
    new_roles.select do |card|
      !Card.fetch(card, "*members").ok? :update
    end
  end
end

def with_old_role_permissions
  new_roles = item_cards
  new_content = content
  Auth.update_always_cache Card::Auth.as_id, nil
  left.with_clear_roles do
    self.content = db_content_before_act
    yield new_roles
  end
ensure
  self.content = new_content
end
