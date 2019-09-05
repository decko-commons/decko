include_set Abstract::Accounted

require_field :account

def default_account_status
  can_approve? ? "unverified" : "unapproved"
end

# callback from +*account card
def activate!
  self.type_id = Card.default_accounted_type_id
end

def can_approve?
  return @can_approve if !@can_approve.nil?
  @can_approve = Card.new(type_id: Card.default_accounted_type_id).ok? :create
end

event :auto_approve_with_verification, :validate, on: :create, when: :can_approve? do
  request_verification
end

event :approve_with_verification, :validate, on: :update, trigger: :required do
  approvable do
    account_subfield.add_subfield :status, content: "unverified"
    request_verification
  end
end

event :approve_without_verification, :validate, on: :update, trigger: :required do
  # TODO: if validated here, add trigger and activate in storage phase
  approvable { account_subfield.activate! }
end

event :act_as_current_for_integrate_stage, :integrate, on: :create do
  Auth.current_id = id
end

def account_subfield
  subfield(:account) || add_subfield(:account)
end

def request_verification
  account_subfield.trigger_event! :send_verification_email
end

def approvable
  if can_approve?
    yield
  else
    abort :failure, "illegal approval" # raise permission denied?
  end
end
