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
  Card::Virtual.fetch_content(self)
end

# called to refresh the virtual content
# the default way is to use the card's template content
def generate_virtual_content
  template&.db_content
end

event :save_virtual_content, :prepare_to_store, on: :save, changed: :content do
  Card::Virtual.create_or_update(self, attributes["db_content"])
  abort :success
end

event :delete_virtual_content, :prepare_to_store, on: :delete do
  Card::Virtual.find_by_card(self)&.delete
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
