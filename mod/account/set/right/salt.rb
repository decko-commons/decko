include_set Abstract::AccountField

assign_type :phrase

def generate
  self.content = Digest::SHA1.hexdigest "--#{Time.zone.now}--"
end

def history?
  false
end

view :raw do
  t :account_private_data
end
