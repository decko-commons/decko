def follow follow_name, option="*always"
  return unless (follow_rule = Card.fetch(follow_name)&.follow_rule_card(name, new: {}))
  follow_rule.drop_item "*never"
  follow_rule.add_item option
  follow_rule.save!
end
