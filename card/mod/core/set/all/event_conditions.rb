def event_applies? event
  return unless set_condition_applies? event.set_module, event.opts[:changing]

  Card::Set::Event::CONDITIONS.all? do |key|
    send "#{key}_condition_applies?", event, event.opts[key]
  end
end

private

def set_condition_applies? set_module, old_sets
  return true if set_module == Card

  set_condition_card(old_sets).singleton_class.include? set_module
end

def on_condition_applies? _event, actions
  actions = Array(actions).compact
  return true if actions.empty?
  actions.include? @action
end

# if changing name/type, the old card has no-longer-applicable set modules, so we create
# a new card to determine whether events apply.
# (note: cached condition card would ideally be cleared after all
# conditions are reviewed)
# @param old_sets [True/False] whether to use the old_sets
def set_condition_card old_sets
  return self if old_sets || no_current_action?
  @set_condition_card ||=
    updating_sets? ? set_condition_card_with_new_set_modules : self
end

# existing card is being changed in a way that alters its sets
def updating_sets?
  @action == :update && real? && (type_id_is_changing? || name_is_changing?)
end

# prevents locking in set_condition_card
def no_current_action?
  return false if @current_action

  @set_condition_card = nil
  true
end

def set_condition_card_with_new_set_modules
  cc = Card.find id
  cc.name = name
  cc.type_id = type_id
  cc.include_set_modules
end

def changed_condition_applies? _event, db_columns
  return true unless @action == :update
  db_columns = Array(db_columns).compact
  return true if db_columns.empty?
  db_columns.any? { |col| single_changed_condition_applies? col }
end
alias_method :changing_condition_applies?, :changed_condition_applies?

def when_condition_applies? _event, block
  case block
  when Proc then block.call(self)
  when Symbol then send block
  else true
  end
end

def skip_condition_applies? event, allowed
  return true if skip_events.empty?
  event = event.name.to_s
  !(standard_skip_event?(event, allowed) || force_skip_event?(event))
end

def trigger_condition_applies? event, required
  return true unless required == :required
  trigger_event? event
end

def single_changed_condition_applies? db_column
  return true unless db_column
  db_column =
    case db_column.to_sym
    when :content then "db_content"
    when :type    then "type_id"
    else db_column.to_s
    end
  attribute_is_changing?(db_column)
end

def wrong_stage opts
  return false if director.stage_ok? opts
  if !stage
    "phase method #{method} called outside of event phases"
  else
    "#{opts.inspect} method #{method} called in stage #{stage}"
  end
end

def wrong_action action
  return false if on_condition_applies?(nil, action)
  "on: #{action} method #{method} called on #{@action}"
end

def standard_skip_event? event, allowed
  return false unless allowed == :allowed
  skip_events.include? event
end

def force_skip_event? event
  forced_skip_events.include? event
end

def forced_skip_events
  @forced_skip_events ||= ::Set.new(skip_events.find_all { |e| e.last == "!" })
end

def skip_events
  @skip_events ||= begin
    events = Array.wrap(skip_event_in_action) + Array.wrap(act_card.skip_event)
    ::Set.new events.map(&:to_s)
  end
end

def trigger_event? event
  @names_of_triggered_events ||= triggered_events
  @names_of_triggered_events.include? event.name
end

def triggered_events
  events = Array.wrap(trigger_event_in_action) + Array.wrap(act_card.trigger_event)
  ::Set.new events.map(&:to_sym)
end
