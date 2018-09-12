# -*- encoding : utf-8 -*-

describe Card::Set::All::Bridge::TabViews do
  check_views_for_errors :engage_tab, :history_tab, :related_tab, :rules_tab,
                         :account_tab, :follow_section
end
