# -*- encoding : utf-8 -*-

class AddRuleCard < Card::Migration::Core
  def up
    ensure_card "*rule", codename: "rule", type_id: Card::SetID

    # the following re-registers set patterns, now including the rule pattern
    Cardio::Mod::Loader.reload_sets
  end
end
