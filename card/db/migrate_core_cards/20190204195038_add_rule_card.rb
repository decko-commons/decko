# -*- encoding : utf-8 -*-

class AddRuleCard < Card::Migration::Core
  def up
    ensure_card "*rule", codename: "rule"
  end
end
