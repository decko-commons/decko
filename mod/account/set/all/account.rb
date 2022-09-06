module ClassMethods
  def default_accounted_type_id
    UserID
  end
end

def account
  fetch :account
end

def parties
  @parties ||= (all_enabled_roles << id).flatten.reject(&:blank?)
end

def among? ok_ids
  ok_ids.any? do |ok_id|
    ok_id == AnyoneID ||
      # (ok_id == AnyoneWithRoleID && all_enabled_roles.size > 1) ||
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

def read_rules_hash
  @read_rules_hash ||= read_rules.each_with_object({}) { |id, h| h[id] = true }
end

def fetch_read_rules
  return [] if id == WagnBotID # always_ok, so not needed

  ([AnyoneID] + parties).each_with_object([]) do |party_id, rule_ids|
    next unless (cache = Card::Rule.read_rule_cache[party_id])

    rule_ids.concat cache
  end
end

def clear_roles
  @parties = @all_roles = @all_active_roles = @read_rules = nil
end

# def with_clear_roles
#   a = @parties
#   b = @all_roles
#   c = @all_active_roles
#   d = @read_rules
#   yield
# ensure
#   @parties = a
#   @all_roles = b
#   @all_active_roles = c
#   @read_rules = d
# end

def all_enabled_roles
  @all_active_roles ||= (id == AnonymousID ? [] : enabled_role_ids)
end

def all_roles
  @all_roles ||= (id == AnonymousID ? [] : fetch_roles)
end

def enabled_role_ids
  with_enabled_roles do |enabled|
    enabled.virtual? ? enabled.item_ids : fetch_roles
  end
end

def with_enabled_roles
  Auth.as_bot do
    Card::Codename.exists?(:enabled_roles) ? yield(enabled_roles_card) : fetch_roles
  end
end

def enabled_roles_card
  fetch :enabled_roles, eager_cache: true, new: { type_id: SessionID }
end

def fetch_roles
  [AnyoneSignedInID] + role_ids_from_role_member_cards
end

def role_ids_from_role_member_cards
  ids = Card.search(left: { type_id: Card::RoleID }, right_id: Card::MembersID)
  Self::Role.role_ids id
end

event :generate_token do
  Digest::SHA1.hexdigest "--#{Time.zone.now.to_f}--#{rand 10}--"
end

event :set_stamper, :prepare_to_validate do
  self.updater_id = Auth.current_id
  self.creator_id = updater_id if new_card?
end
