include_set Abstract::VirtualSet

assign_type :set

def cql_content
  { left: { type: "_LL" }, right: "_LR" }
end

def related_sets _with_self=false
  [self, Card.fetch(name[1], :right)]
end
