
# The Card#abort method is for cleanly exiting an action without continuing
# to process any further events.
#
# Three statuses are supported:
#
#   failure: adds an error, returns false on save
#   success: no error, returns true on save
#   triumph: similar to success, but if called on a subcard
#            it causes the entire action to abort (not just the subcard)
def abort status, msg="action canceled"
  director.abort
  if status == :failure && errors.empty?
    errors.add :abort, msg
  elsif status.is_a?(Hash) && status[:success]
    success << status[:success]
    status = :success
  end
  raise Card::Error::Abort.new(status, msg)
end

def aborting
  yield
  errors.any? ? abort(:failure) : abort(:success)
end

def abortable
  yield
rescue Card::Error::Abort => e
  handle_abort_error e
end

def actify &block
  @action || identify_action
  if ActManager.act_card
    add_to_act &block
  else
    start_new_act &block
  end
end

private

def handle_abort_error e
  if e.status == :triumph
    @supercard ? raise(e) : true
  elsif e.status == :success
    abort_success
  end
end

def abort_success
  if @supercard
    @supercard.subcards.delete key
    @supercard.director.subdirectors.delete self
    expire :soft
  end
  true
end

def start_new_act
  self.director = nil
  ActManager.run_act(self) do
    run_callbacks(:act) { yield }
  end
end

def add_to_act
  director.reset_stage
  director.update_card self
  self.only_storage_phase = true
  yield
end

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

# This prevents problems related to
def raise_if_duplicate_call method
  @called ||= {}
  return unless @called[method]
  raise Card::Error::ServerError,
        "attempted multiple #{method} calls on #{name} card in one act"
end

def in_act caller_method, &block
  call_only_once caller_method do |called|
    return yield if called
    actify &block
  end
end

# this is an override of standard rails behavior that rescues abort
# makes it so that :success abortions do not rollback
def with_transaction_returning_status
  caller_method = caller_locations(1,1)[0].label
  status = nil
  in_act caller_method do
    self.class.transaction do
      add_to_transaction
      status = abortable { yield }
      raise ActiveRecord::Rollback unless status
    end
  end
  status
end

# FIXME: these two do not belong here!

event :notable_exception_raised do
  error = Card::Error.current
  Rails.logger.debug "#{error.message}\n#{error.backtrace * "\n  "}"
end

def success
  Env.success(name)
end

