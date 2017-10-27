include Abstract::Permission

format :html do include Abstract::Permission::HtmlFormat end

event :cascade_read_rule, :finalize, after: :update_rule_cache,
                                     when: :is_rule? do
  return unless name_is_changing? || trash_is_changing?
  update_read_ruled_cards rule_set
end


def update_read_ruled_cards set
  self.class.clear_read_rule_cache
  Card.cache.reset # maybe be more surgical, just Auth.user related
  expire # probably shouldn't be necessary,
  # but was sometimes getting cached version when card should be in the
  # trash.  could be related to other bugs?

  updated = update_read_rules_of_set_members set

  # then find all cards with me as read_rule_id that were not just updated
  # and regenerate their read_rules
  return if new_card?
  Card.search(read_rule_id: id) do |card|
    card.update_read_rule unless updated.include?(card.key)
  end
end

def update_read_rules_not_overridden_by_narrower_rules cur_index,
                                                       rule_class_index, set
  set.item_cards(limit: 0).each_with_object(::Set.new) do |item_card, in_set|
    in_set << item_card.key
    next if cur_index < rule_class_index
    item_card.update_read_rule
  end
end




event :process_read_rule_update_queue, :finalize do
  Array.wrap(@read_rule_update_queue).each(&:update_read_rule)
  @read_rule_update_queue = []
end

def update_read_rules_of_set_members set
  return ::Set.new if trash || !(class_id = id_of_set_class(set))
  rule_class_ids = set_patterns.map(&:pattern_id)
  Auth.as_bot do
    if (rule_class_index = rule_class_ids.index(class_id))
      cur_index = rule_class_ids.index Card[read_rule_class].id
      update_read_rules_not_overridden_by_narrower_rules cur_index,
                                                         rule_class_index, set
    else
      warn "No current rule index #{class_id}, #{rule_class_ids.inspect}"
      ::Set.new
    end
  end
end