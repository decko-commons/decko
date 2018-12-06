include All::Permissions::Accounts

def history?
  false
end

view :raw do
  tr :private_data
end
