module ClassMethods
  def repair_all_permissions
    Card.where("(read_rule_class is null or read_rule_id is null) and trash is false")
        .each do |broken_card|
      broken_card.include_set_modules
      broken_card.repair_permissions!
    end
  end
end

def repair_permissions!
  rule_id, rule_class = permission_rule_id_and_class :read
  update_columns read_rule_id: rule_id, read_rule_class: rule_class
end

# ok? and ok! are public facing methods to approve one action at a time
#
#   fetching: if the optional :trait parameter is supplied, it is passed
#      to fetch and the test is perfomed on the fetched card, therefore:
#
#      trait: :account      would fetch this card plus a tag codenamed :account
#      trait: :roles, new: {} would initialize a new card with default ({})
# options.

def ok? action
  @action_ok = true
  send "ok_to_#{action}"
  @action_ok
end

def ok_with_fetch? action, opts={}
  card = opts[:trait].nil? ? self : fetch(opts)
  card && card.ok_without_fetch?(action)
end

# note: method is chained so that we can return the instance variable @action_ok
alias_method_chain :ok?, :fetch

def ok! action, opts={}
  raise Card::Error::PermissionDenied, self unless ok? action, opts
end

def who_can action
  permission_rule_card(action).item_cards.map(&:id)
end

def anyone_can? action
  who_can(action).include? Card::AnyoneID
end

def direct_rule_card action
  direct_rule_id = rule_card_id action
  require_permission_rule! direct_rule_id, action
  Card.fetch direct_rule_id, skip_modules: true
end

def permission_rule_id action
  direct_rule = direct_rule_card action
  applicable_permission_rule_id direct_rule, action
end

def permission_rule_id_and_class action
  direct_rule = direct_rule_card action
  [
    applicable_permission_rule_id(direct_rule, action),
    direct_rule.rule_class_name
  ]
end

def applicable_permission_rule_id direct_rule, action
  if junction? && direct_rule.db_content =~ /^\[?\[?_left\]?\]?$/
    left_permission_rule_id action
  else
    direct_rule.id
  end
end

def left_permission_rule_id action
  lcard = left_or_new(skip_virtual: true, skip_modules: true)
  if action == :create && lcard.real? && lcard.action != :create
    action = :update
  end
  lcard.permission_rule_id action
end

def permission_rule_card action
  Card.fetch permission_rule_id(action)
end

def require_permission_rule! rule_id, action
  return if rule_id
  # RULE missing.  should not be possible.
  # generalize this to handling of all required rules
  errors.add :permission_denied, tr(:error_no_action_rule, action: action, name: name)
  raise Card::Error::PermissionDenied, self
end

def rule_class_name
  trunk.type_id == Card::SetID ? name.trunk_name.tag : nil
end

def you_cant what
  "You don't have permission to #{what}"
end

def deny_because why
  @permission_errors << why if @permission_errors
  @action_ok = false
end

def permitted? action
  return false if Card.config.read_only # :read does not call #permit
  return true if Auth.always_ok?

  Auth.as_card.among? who_can(action)
end

def permit action, verb=nil
  # not called by ok_to_read
  deny_because "Currently in read-only mode" if Card.config.read_only

  return if permitted? action
  verb ||= action.to_s
  deny_because you_cant("#{verb} #{name.present? ? name : 'this'}")
end

def ok_to_create
  permit :create
  return if !@action_ok || !junction?

  %i[left right].each do |side|
    # left is supercard; create permissions will get checked there.
    next if side == :left && @superleft
    part_card = send side, new: {}
    # if no card, there must be other errors
    next unless part_card && part_card.new_card?
    unless part_card.ok? :create
      deny_because you_cant("create #{part_card.name}")
    end
  end
end

def ok_to_read
  return if Auth.always_ok?
  @read_rule_id ||= permission_rule_id(:read)
  return if Auth.as_card.read_rules.member? @read_rule_id
  deny_because you_cant "read this"
end

def ok_to_update
  permit :update
  if @action_ok && type_id_changed? && !permitted?(:create)
    deny_because you_cant("change to this type (need create permission)")
  end
  ok_to_read if @action_ok
end

def ok_to_delete
  permit :delete
end

# don't know why we introduced this
# but we have to preserve read rules to make
# delete acts visible in recent changes -pk
# event :clear_read_rule, :store, on: :delete do
#   self.read_rule_id = self.read_rule_class = nil
# end

event :set_read_rule, :store,
      on: :save, changed: %i[type_id name] do
  read_rule_id, read_rule_class = permission_rule_id_and_class(:read)
  self.read_rule_id = read_rule_id
  self.read_rule_class = read_rule_class
end

event :set_field_read_rules,
      after: :set_read_rule, on: :update, changed: :type_id do
  # find all cards with me as trunk and update their read_rule
  # (because of *type plus right)
  # skip if name is updated because will already be resaved

  Auth.as_bot do
    fields.each do |field|
      field.refresh.update_read_rule
    end
  end
end

# currently doing a brute force search for every card that may be impacted.
# may want to optimize(?)
def update_field_read_rules
  Auth.as_bot do
    fields.each do |field|
      field.update_read_rule if field.rule(:read) == "_left"
    end
  end
end

def without_timestamps
  Card.record_timestamps = false
  yield
ensure
  Card.record_timestamps = true
end

event :update_read_rule do
  without_timestamps do
    reset_patterns # why is this needed?
    rcard_id, rclass = permission_rule_id_and_class :read
    # these two are just to make sure vals are correct on current object
    self.read_rule_id = rcard_id
    self.read_rule_class = rclass
    Card.where(id: id).update_all read_rule_id: rcard_id,
                                  read_rule_class: rclass
    expire :hard
    update_field_read_rules
  end
end

def add_to_read_rule_update_queue updates
  @read_rule_update_queue = Array.wrap(@read_rule_update_queue).concat updates
end

event :check_permissions, :validate do
  track_permission_errors do
    ok? action_for_permission_check
  end
end

def action_for_permission_check
  commenting? ? :update : @action
end

def track_permission_errors
  @permission_errors = []
  result = yield
  @permission_errors.each { |msg| errors.add :permission_denied, msg }
  @permission_errors = nil
  result
end

module AccountField
  # allow account owner to update account field content
  def ok_to_update
    return true if own_account? && !name_changed? && !type_id_changed?

    super
  end

  # force inherit permission on create
  # (cannot be done with rule, because sets are not addressable)
  def applicable_permission_rule_id _direct_rule, action
    return left_permission_rule_id action if action == :create

    super
  end
end
