def virtual?
  new?
end

# supports legacy references to <User>+*email
# (standard representation is now <User>+*account+*email)
view :raw do
  card.content_email || card.account_email || ""
end

def content_email
  content if real?
end

def account_email
  left&.account&.email
end
