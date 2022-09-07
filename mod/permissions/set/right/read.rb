include Abstract::Permission

assign_type :list

format :html do include Abstract::Permission::HtmlFormat end

event :cascade_read_rule, :finalize, after: :update_rule_cache, when: :rule? do
  return unless name_is_changing? || trash_is_changing?

  update_read_ruled_cards
end

def update_read_ruled_cards
  Card::Rule.clear_read_rule_cache
  Card.cache.reset # maybe be more surgical, just Auth.user related
  expire # probably shouldn't be necessary,
  # but was sometimes getting cached version when card should be in the
  # trash.  could be related to other bugs?

  processed = update_read_rules_of_set_members
  update_cards_with_read_rule_id processed unless new?
end

def update_read_rules_of_set_members
  return unless rule_pattern_index

  each_member do |member, processed|
    processed << member.key
    member.update_read_rule
    member.update_read_rule unless member_has_overriding_rule?(member)
  end
end

def member_has_overriding_rule? member
  pattern_index(member.read_rule_class.card_id) < rule_pattern_index
end

# cards with this card as a read_rule_id
# These may include cards that are no longer set members if the card was renamed
# (edge case)
def update_cards_with_read_rule_id processed
  processed ||= ::Set.new
  Card::Auth.as_bot do
    Card.search(read_rule_id: id) do |card|
      card.update_read_rule unless processed.include?(card.key)
    end
  end
end

def each_member &block
  Auth.as_bot do
    all_members.each_with_object(::Set.new, &block)
  end
end

def all_members
  rule_set.item_cards limit: 0
end

def rule_pattern_index
  return if trash

  @rule_pattern_index ||= pattern_index rule_set&.tag&.id
end

def pattern_index pattern_id
  Pattern.ids.index(pattern_id) || invalid_pattern_id(pattern_id)
end

def invalid_pattern_id pattern_id
  Rails.logger.info "invalid pattern id for read rule: #{pattern_id}"
end

event :process_read_rule_update_queue, :finalize do
  left&.update_read_rule
end
