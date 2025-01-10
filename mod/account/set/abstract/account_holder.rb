event :validate_account_holder_name_change, :validate, on: :update, changed: :name do
  return unless account? && !Card::Auth.as_card.account_manager?

  errors.add :name, "cannot rename Account Holder"
end

def account
  fetch :account, new: {}
end

def account?
  account.real?
end

def own_account?
  key == Auth.as_card.key
end

def default_account_status
  "active"
end

def current_account?
  id && Auth.current_id == id
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

def all_enabled_roles
  @all_enabled_roles ||= (id == AnonymousID ? [] : enabled_role_ids)
end

def all_roles
  @all_roles ||= (id == AnonymousID ? [] : fetch_roles)
end

def read_rules
  @read_rules ||= fetch_read_rules
end

def read_rules_hash
  @read_rules_hash ||= read_rules.each_with_object({}) { |id, h| h[id] = true }
end

def clear_roles
  @parties = @all_roles = @all_enabled_roles = @read_rules = nil
end

def ok_to_update?
  (own_account? && !type_id_changed?) || super
end

def admin?
  role? AdministratorID
end

def role? role_mark
  all_enabled_roles.include? role_mark.card_id
end

def account_manager?
  own_account? || parties.member?(HelpDeskID)
end

private

def enabled_role_ids
  with_enabled_roles do |enabled|
    enabled.virtual? ? enabled.item_ids : fetch_roles
  end
end

def with_enabled_roles
  Auth.as_bot do
    Card::Codename.exist?(:enabled_roles) ? yield(enabled_roles_card) : fetch_roles
  end
end

def enabled_roles_card
  fetch :enabled_roles, eager_cache: true, new: { type_id: SessionID }
end

def role_ids_from_role_member_cards
  Self::Role.role_ids id
end

def fetch_roles
  [AnyoneSignedInID] + role_ids_from_role_member_cards
end

def fetch_read_rules
  return [] if id == WagnBotID # always_ok, so not needed

  ([AnyoneID] + parties).each_with_object([]) do |party_id, rule_ids|
    next unless (cache = Card::Rule.read_rule_cache[party_id])

    rule_ids.concat cache
  end
end

format :html do
  def default_board_tab
    card.current_account? ? :account_tab : super
  end

  view :account_tab do
    board_pill_sections "Account" do
      [["Settings", account_details_items],
       ["Content", account_content_items]]
    end
  end

  def show_account_tab?
    card.account?
  end

  def account_formgroups
    Auth.as_bot do
      subformat(card.account)._render :content_formgroups, structure: true
    end
  end

  def account_details_items
    [
      ["Email and Password", :account,
       { path: { slot: { hide: %i[help_link board_link] } } }],
      ["Roles", :roles,
       { path:  { view: :content } }],
      ["Notifications", :follow],
      # FIXME: this should be added in api_key mod!
      ["API", :account,
       { path: { view: :api_key,
                 items: { view: :content },
                 slot: { hide: %i[help_link board_link] } } }]
    ]
  end

  def account_content_items
    [["Created", :created],
     ["Edited", :edited]]
  end
end
