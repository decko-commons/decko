def related_sets with_self=false
  sets = []
  sets << ["#{name}+*type", Card::Set::Type.label(name)] if known?
  sets + super
end
