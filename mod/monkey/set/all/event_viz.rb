# the events method is a developer's tool for visualizing the event order
# for a given card.
# For example, from a console you might run
#
#   puts mycard.events :update
#
# to see the order of events that will be executed on mycard.
# The indention and arrows (^v) indicate event dependencies.
#
# Note: as of yet, the functionality is a bit rough.  It does not display events
# that are called directly from within other events,
# and certain event requirements (like the presence of an 'act') may
# prevent events from showing up in the tree.
def events action
  @action = action
  events = Director::Stages::SYMBOLS.map { |stage| events_tree "#{stage}_stage" }
  @action = nil
  print_events events
end

def events_tree filt
  try("_#{filt}_callbacks")&.each_with_object({ name: filt }) do |callback, hash|
    events_branch hash, callback.kind, callback.filter if callback.applies? self
  end
end

private

def print_events events, prefix="", depth=0
  depth += 1
  space = " " * (depth * 2)
  text = ""
  events.each do |event|
    text += print_event_pre event, depth, space
    text += print_event_main event, prefix
    text += print_event_post event, depth, space
  end
  text
end

def print_event_pre event, depth, space
  if event[:before]
    print_events event[:before], "#{space}v  ", depth
  elsif event[:around]
    print_events event[:around], "#{space}vv ", depth
  else
    ""
  end
end

def print_event_main event, prefix
  "#{prefix}#{event[:name]}\n"
end

def print_event_post event, depth, space
  return "" unless event[:after]

  print_events event[:after], "#{space}^  ", depth
end

def events_branch hash, kind, filter
  hash[kind] ||= []
  hash[kind] << events_tree(filter)
end
