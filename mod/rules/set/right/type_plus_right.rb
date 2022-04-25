include_set Abstract::VirtualSet

assign_type :set

def cql_content
  { left: { type: "_LL" }, right: "_LR" }
end

def related_sets _with_self=false
  [[name, Card::Set::TypePlusRight.label(name.left)],
   ["#{name[1]}+*right", Card::Set::Right.label(name[1])]]
end
