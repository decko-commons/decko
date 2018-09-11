def event_applies? event
  return unless set_condition_applies? event.set_module

  Card::Set::Event::CONDITIONS.all? do |key|
    send "#{key}_condition_applies?", event, event.opts[key]
  end
end

private

def set_condition_applies? set_module
  # events on Card are used for testing
  set_module == Card || singleton_class.include?(set_module)
end

def on_condition_applies? _event, actions
  actions = Array(actions).compact
  return true if actions.empty?
  actions.include? @action
end

def changed_condition_applies? _event, db_columns
  return true unless @action == :update
  db_columns = Array(db_columns).compact
  return true if db_columns.empty?
  db_columns.any? { |col| single_changed_condition_applies? col }
end

def when_condition_applies? _event, block
  case block
  when Proc then block.call(self)
  when Symbol then send block
  else true
  end
end

def skip_condition_applies? event, allowed
  return true unless allowed == :allowed
  !skip_event? event
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

def skip_event? event
  @names_of_skipped_events ||= skipped_events
  @names_of_skipped_events.include? event.name
end

def skipped_events
  events = Array.wrap(skip_event_in_action) + Array.wrap(act_card.skip_event)
  ::Set.new events.map(&:to_sym)
end

def trigger_event? event
  @names_of_triggered_events ||= triggered_events
  @names_of_triggered_events.include? event.name
end

def triggered_events
  events = Array.wrap(trigger_event_in_action) + Array.wrap(act_card.trigger_event)
  ::Set.new events.map(&:to_sym)
end
