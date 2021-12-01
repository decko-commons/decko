# -*- encoding : utf-8 -*-

def virtual?
  new?
end

def history?
  false
end

def followable?
  false
end

def db_content
  Virtual.fetch(self)&.content
end

def updated_at
  Virtual.fetch(self)&.updated_at
end

def virtual_content
  attributes["db_content"]
end

event :save_virtual_content, :prepare_to_store, on: :save, changed: :content do
  Virtual.save self, attributes["db_content"]
  abort :success
end

event :delete_virtual_content, :prepare_to_store, on: :delete do
  Virtual.delete self
  abort :success
end

def delete
  # delete although it's new
  update trash: true
end

def delete!
  # delete although it's new
  update! trash: true
end
