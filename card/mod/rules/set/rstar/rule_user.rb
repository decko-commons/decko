
def rule_user_name
  is_preference? ? name.trunk_name.tag : nil
end

def rule_user
  is_preference? ? self[-2] : nil
end
