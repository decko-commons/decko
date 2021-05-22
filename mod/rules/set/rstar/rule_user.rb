def rule_user_name
  preference? ? name.trunk_name.tag : nil
end

def rule_user
  preference? ? self[-2] : nil
end
