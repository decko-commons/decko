include_set Pointer

def virtual?
  session_content.present?
end

def history?
  false
end

def followable?
  false
end

def session_key
  "_card_#{key}"
end

def session_content
  Env.session[session_key]
end

def session_content= val
  Env.session[session_key] = val
end

def content
  db_content || session_content
end

event :store_in_session, :prepare_to_store, on: :save do
  self.session_content = db_content
  abort :success
end

event :delete_in_session, :prepare_to_store, on: :delete do
  self.session_content = nil
  abort :success
end

def add_to_trash args
  yield args.merge trash: true
end

format :html do
  before :core do
    voo.items[:view] = :name
  end
end
