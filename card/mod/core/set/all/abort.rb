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

private

def handle_abort_error e
  case e.status
  when :triumph
    @supercard ? raise(e) : true
  when :success
    abort_success
  end
end

def abort_success
  if @supercard
    @supercard.subcards.remove key
    @supercard.director.subdirectors.delete self
  end
  expire :soft
  true
end

# this is an override of standard rails behavior that rescues abort
# makes it so that :success abortions do not rollback
def with_transaction_returning_status &block
  status = nil
  self.class.transaction do
    add_to_transaction
    remember_transaction_record_state
    status = abortable(&block)
    raise ActiveRecord::Rollback unless status
  end
  status
end

# FIXME: these two do not belong here!

public

event :notable_exception_raised do
  error = Card::Error.current
  Rails.logger.debug "#{error.message}\n#{error.backtrace * "\n  "}"
end

def success
  Env.success(name)
end
