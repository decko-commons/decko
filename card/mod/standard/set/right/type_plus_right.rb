def related_sets _with_self=false
  [[name, Card::Set::TypePlusRight.label(name.left)],
   ["#{name[1]}+*right", Card::Set::Right.label(name[1])]]
end
