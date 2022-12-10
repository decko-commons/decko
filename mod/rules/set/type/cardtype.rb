def related_sets with_self=false
  sets = []
  sets << Card.fetch(name, :type) if known?
  sets + super
end
