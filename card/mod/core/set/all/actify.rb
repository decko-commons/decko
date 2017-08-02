
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

def act opts={}, &block
  if ActManager.act_card
    add_to_act opts, &block
  else
    start_new_act opts, &block
  end
end

def start_new_act opts
  ActManager.clear
  self.director = nil
  ActManager.act_card = self
  if opts && opts[:success]
    Env[:success] = Env::Success.new(cardname, Env.params[:success])
  end
  run_callbacks :act do
    yield
  end
ensure
  ActManager.clear
end

def add_to_act opts
  # if only_storage_phase is true then the card is already part of the act
  return yield if ActManager.act_card == self || only_storage_phase
  director.reset_stage
  if opts && opts[:trash]
    @action = :delete
  else
    identify_action
  end
  director.update_card self
  self.only_storage_phase = true
  yield
end

module ClassMethods
  def create! opts
    card = Card.new opts
    card.act do
      card.save!
    end
    card
  end

  def create opts
    card = Card.new opts
    card.act do
      card.save
    end
    card
  end
end

def save!(*)
  act { super }
end

def save(*)
  act { super }
end

def valid?(*)
  act { super }
end

def update_attributes *args
  act(*args) { super }
end

def update_attributes! *args
  act(*args) { super }
end

def abortable
  yield
rescue Card::Error::Abort => e
  if e.status == :triumph
    @supercard ? raise(e) : true
  elsif e.status == :success
    if @supercard
      @supercard.subcards.delete key
      @supercard.director.subdirectors.delete self
      expire :soft
    end
    true
  end
end

# this is an override of standard rails behavior that rescues abort
# makes it so that :success abortions do not rollback
def with_transaction_returning_status
  status = nil
  self.class.transaction do
    add_to_transaction
    status = abortable { yield }
    raise ActiveRecord::Rollback unless status
  end
  status
end

event :notable_exception_raised do
  error = Card::Error.current
  Rails.logger.debug "#{error.message}\n#{error.backtrace * "\n  "}"
end

def success
  Env.success(cardname)
end

def name_before_act
  name_before_last_save || name_was
end

def db_content_before_act
  db_content_before_last_save || db_content_was
end
