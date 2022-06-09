delegate :accounted, to: :account_card

def account_card
  left
end

# allow account owner to update account field content
def ok_to_update
  (own_account? && !name_changed? && !type_id_changed?) || super
end

# force inherit permission on create
# (cannot be done with rule, because sets are not addressable)
def permission_rule_id action
  if action == :create
    left_permission_rule_id action
  else
    super
  end
end
