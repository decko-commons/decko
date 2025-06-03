include_set Abstract::AccountField
include_set Abstract::List

assign_type :phrase

format :html do
  def input_type
    :radio
  end
end

def option_names
  Card::Set::Right::Account::STATUS_OPTIONS
end

def ok_to_update?
  if own_account? && !Auth.always_ok?
    deny_because you_cant(t(:account_deny_not_change_own_account))
  else
    super
  end
end
