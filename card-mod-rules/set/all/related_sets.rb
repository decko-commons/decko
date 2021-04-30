def related_sets with_self=false
  # refers to sets that users may configure from the current card -
  # NOT to sets to which the current card belongs

  [].tap do |sets|
    sets << [self_set_name, self_set_label] if with_self
    sets << [right_set_name, right_set_label] if known? && simple?
  end
end

def self_set_name
  Name[name, :self]
end

def self_set_label
  Card::Set::Self.label name
end

def right_set_name
  Name[name, :right]
end

def right_set_label
  Card::Set::Right.label name
end
