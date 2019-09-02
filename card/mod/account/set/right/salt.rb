include All::Permissions::AccountField

def history?
  false
end

view :raw do
  tr :private_data
end
