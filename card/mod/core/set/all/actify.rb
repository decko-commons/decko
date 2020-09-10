def act &block
  if act_card
    add_to_act &block
  else
    start_new_act &block
  end
end

def act_card
  Card::Director.act_card
end

def act_card?
  self == act_card
end

def clear_action_specific_attributes
  self.class.action_specific_attributes.each do |attr|
    instance_variable_set "@#{attr}", nil
  end
end

module ClassMethods
  def create! opts
    card = Card.new opts
    card.save!
    card
  end

  def create opts
    card = Card.new opts
    card.save
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

def update *args
  act { super }
end

def update! *args
  act { super }
end

alias_method :update_attributes, :update
alias_method :update_attributes!, :update!

private

def start_new_act
  self.director = nil
  Director.run_act(self) do
    run_callbacks(:act) { yield }
  end
end

def add_to_act
  director.appoint self unless @director
  yield
end
