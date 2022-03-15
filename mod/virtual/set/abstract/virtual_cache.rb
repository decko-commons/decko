# -*- encoding : utf-8 -*-

def virtual?
  new?
end

# the content to be cached
# (can be overridden)
def virtual_content
  attributes["db_content"]
end

def db_content
  Virtual.fetch(self)&.content
end

def updated_at
  Virtual.fetch(self)&.updated_at
end

event :save_virtual_content, :prepare_to_store, on: :save do
  Virtual.save self
  abort :success
end

event :delete_virtual_content, :prepare_to_store, on: :delete do
  Virtual.delete self
  abort :success unless real?
end

# TODO: confirm that the following are needed (and if so, explain why)
# in theory, if we always abort, we'll never trigger history/follow events,
# and we'll never have a card to delete, no?

def history?
  false
end

def followable?
  false
end

def delete
  # delete although it's new
  update trash: true
end

def delete!
  # delete although it's new
  update! trash: true
end
