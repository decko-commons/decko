include All::Permissions::Accounts

def ok_to_update
  if own_account? && !Auth.always_ok?
    deny_because you_cant(tr(:deny_not_change_own_account))
  else
    super
  end
end
