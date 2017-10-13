
include All::Permissions::Accounts

view :editor do
  card.content = ""

  # HACK
  autocomplete = if @parent && @parent.card.name == "*signin+*account"
                   "on"
                 else
                   "off"
                 end
  password_field :content, class: "d0-card-content", autocomplete: autocomplete
end

view :raw do
  "<em>#{tr :encrypted}</em>"
end

event :encrypt_password, :store,
      on: :save, changed: :content,
      when: proc { !Card::Env[:no_password_encryptions] } do
  # no_password_encryptions = hack for import - fix with api for ignoring events
  salt = get_salt
  # HACK: fix with better ORM handling
  salt = Card::Env[:salt] unless salt.present?
  self.content = Auth.encrypt content, salt

  # errors.add :password, 'need a valid salt'
  # turns out we have a lot of existing account without a salt.
  # not sure when that broke??
end

def get_salt
  left && left.salt
rescue
  binding.pry
end

event :validate_password, :validate,
      on: :save do
  unless content.length > 3
    errors.add :password, tr(:password_length)
  end
end

event :validate_password_present, :prepare_to_validate, on: :update do
  abort :success if content.blank?
end

def ok_to_read
  own_account? ? true : super
end
