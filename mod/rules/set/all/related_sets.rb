def related_sets with_self=false
  # refers to sets that users may configure from the current card -
  # NOT to sets to which the current card belongs

  [].tap do |sets|
    sets << Card.fetch(name, :self) if with_self
    sets << Card.fetch(name, :right) if known? && simple?
  end
end
