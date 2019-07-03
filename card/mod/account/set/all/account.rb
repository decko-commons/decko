module ClassMethods
  def default_accounted_type_id
    Card::UserID
  end
end

def account
  fetch trait: :account
end

def accountable?
  Card.toggle(rule(:accountable))
end

def parties
  @parties ||= (all_enabled_roles << id).flatten.reject(&:blank?)
end

def among? ok_ids
  ok_ids.any? do |ok_id|
    ok_id == Card::AnyoneID ||
      (ok_id == Card::AnyoneWithRoleID && all_enabled_roles.size > 1) ||
      parties.member?(ok_id)
  end
end

def own_account?
  # card is +*account card of signed_in user.
  name.part_names[0].key == Auth.as_card.key &&
    name.part_names[1].key == Card[:account].key
end

def read_rules
  @read_rules ||= fetch_read_rules
end

def fetch_read_rules
  return [] if id == Card::WagnBotID # always_ok, so not needed

  ([Card::AnyoneID] + parties).each_with_object([]) do |party_id, rule_ids|
    next unless self.class.read_rule_cache[party_id]
    rule_ids.concat self.class.read_rule_cache[party_id]
  end
end

def clear_roles
  @parties = @all_roles = @all_active_roles = @read_rules = nil
end

def with_clear_roles
  a, b, c, d = @parties, @all_roles, @all_active_roles, @read_rules
  yield
ensure
  @parties, @all_roles, @all_active_roles, @read_rules = a, b, c, d
end

def all_enabled_roles
  @all_active_roles ||= (id == Card::AnonymousID ? [] : enabled_role_ids)
end

def all_roles
  @all_roles ||= (id == Card::AnonymousID ? [] : fetch_roles)
end

def enabled_role_ids
  Auth.as_bot do
    role_trait = fetch(trait: :enabled_roles, new: { type_id: SessionID })
    role_trait.virtual? ? role_trait.item_ids : fetch_roles
  end
end

def fetch_roles
  [Card::AnyoneSignedInID] + role_ids_from_roles_trait
end

def role_ids_from_roles_trait
  Auth.as_bot do
    role_trait = fetch trait: :roles
    role_trait ? role_trait.item_ids : []
  end
end

event :generate_token do
  Digest::SHA1.hexdigest "--#{Time.zone.now.to_f}--#{rand 10}--"
end

event :set_stamper, :prepare_to_validate do
  self.updater_id = Auth.current_id
  self.creator_id = updater_id if new_card?
end
