
# FIXME: the following don't really belong here, but they have to come after
# the reference stuff.  we need to organize a bit!

event :update_rule_cache, :finalize, when: :is_rule? do
  self.class.clear_rule_cache
end

def id_of_set_class set
  set && (set_class = set.tag) && set_class.id
end

event :expire_related, :finalize do
  subcards.keys.each do |key|
    Card.cache.soft.delete key
  end
  expire # FIXME: where do we put this. Here it deletes @stage
  reset_patterns
  if is_structure?
    structuree_names.each do |name|
      Card.expire name
    end
  end
end

event :expire_related_names, before: :expire_related, changed: :name do
  # FIXME: look for opportunities to avoid instantiating the following
  descendants.each(&:expire)
  name_referers.each(&:expire)
end
