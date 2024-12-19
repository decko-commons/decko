#### ON CREATE

event :set_default_salt, :prepare_to_validate, on: :create do
  field(:salt).generate
end

event :set_default_status, :prepare_to_validate, on: :create do
  field :status, content: accounted&.try(:default_account_status) || "active"
end

# ON UPDATE

# reset password emails contain a link to update the +*account card
# and trigger this event
event :reset_password, :prepare_to_validate, on: :update, trigger: :required do
  verifying_token :reset_password_success, :reset_password_failure
end

event :verify_and_activate, :prepare_to_validate, on: :update, trigger: :required do
  activatable do
    verifying_token :verify_and_activate_success, :verify_and_activate_failure
    subcard(accounted)&.try :activate_accounted
  end
end

event :password_redirect, :finalize, on: :update, when: :password_redirect? do
  success << { id: name, view: "edit" }
end

# INTEGRATION

%i[password_reset_email verification_email welcome_email].each do |email|
  event :"send_#{email}", :integrate, trigger: :required do
    send_account_email email
  end
end

## EVENT HELPERS

def activatable
  abort :failure, "no field manipulation mid-activation" if subcards.present?
  # above is necessary because activation uses super user (Decko Bot),
  # so allowing subcards would be unsafe
  yield
end

# NOTE: this only works in the context of an action.
# if run independently, it will not activate an account
event :activate_account do
  field :status, content: "active"
  trigger_event! :send_welcome_email
end

def verifying_token success, failure
  requiring_token do |token|
    result = Auth::Token.decode token
    if result.is_a?(String) || (result[:user_id] != accounted_id)
      send failure, result
    else
      send success
    end
  end
end

def requiring_token
  if (token = Env.params[:token])
    yield token
  else
    errors.add :token, "is required"
  end
end

def password_redirect?
  Auth.current_id == accounted_id && password.blank?
end

def verify_and_activate_success
  Auth.signin accounted_id
  Auth.as_bot # use admin permissions for rest of action
  activate_account
  success << ""
end

def verify_and_activate_failure error_message
  send_verification_email
  errors.add :content,
             "Sorry, #{error_message}. Please check your email for a new activation link."
end

def reset_password_success
  Auth.signin accounted_id
  success << { id: name, view: :edit }
  abort :success
end

def reset_password_failure error_message
  Auth.as_bot { send_password_reset_email }
  errors.add :content, t(:account_sorry_email_reset, error_msg: error_message)
end
