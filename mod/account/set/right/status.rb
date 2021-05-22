include_set Abstract::AccountField
include_set Abstract::Pointer

def input_type
  :radio
end

def option_names
  %w[unapproved unverified active blocked system]
end

def ok_to_update
  if own_account? && !Auth.always_ok?
    deny_because you_cant(t(:account_deny_not_change_own_account))
  else
    super
  end
end
