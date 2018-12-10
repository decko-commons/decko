
def actify &block
  @action || identify_action
  if ActManager.act_card
    add_to_act &block
  else
    start_new_act &block
  end
end

def save_as_subcard!
  @subcard_save = true
  self.only_storage_phase = true
  save! validate: false
ensure
  @subcard_save = nil
end

private

def start_new_act
  self.director = nil
  ActManager.run_act(self) do
    run_callbacks(:act) { yield }
  end
end

def add_to_act
  return yield if already_in_act?
  # raise_if_duplicate_director
  director.reset_stage
  director.update_card self
  self.only_storage_phase = true
  yield
end

def already_in_act?
  name.present? && ActManager.directors[self]
end

# def raise_if_duplicate_director
#   return unless
#   raise Card::Error::ServerError,
#         "Cannot add #{name} to act; it's already there."
# end

# This is a workaround to help navigate the fact that in active record,
# #update! calls #with_transaction_returning_status, which calls #save!,
# which ALSO calls #with_transaction_returning_status.
#
# We want to allow one update! and one save! call for a given card in a
# given act.  But we want to raise an error if one of those is called twice.
def call_only_once method
  already = !@called.nil?
  raise_if_duplicate_call method
  @called[method] = true
  yield already
ensure
  @called = nil
end

def raise_if_duplicate_call method
  @called ||= {}
  return unless @called[method]
  raise Card::Error::ServerError,
        "attempted multiple #{method} calls on #{name} card in one act"
end

def in_act caller_method, &block
  return yield if @subcard_save
  call_only_once caller_method do |called|
    return yield if called
    actify &block
  end
end

# this is an override of standard rails behavior that rescues abort
# makes it so that :success abortions do not rollback
def with_transaction_returning_status
  caller_method = caller_locations(1, 1)[0].label
  in_act caller_method do
    super
  end
end

