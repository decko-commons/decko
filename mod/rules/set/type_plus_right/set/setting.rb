assign_type :list

format :html do
end

def item_cards args={}
  left.setting_list(args[:setting_list] || :all).map(&method(:rule_item_card))
end

def rule_item_card setting
  left.fetch setting, new: {}
end
