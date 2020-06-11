
# allow account owner to update account field content
def ok_to_update
  return true if own_account? && !name_changed? && !type_id_changed?

  super
end

# force inherit permission on create
# (cannot be done with rule, because sets are not addressable)
def permission_rule_id action
  return left_permission_rule_id action if action == :create

  super
end
