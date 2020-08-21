attr_writer :director
delegate :act_manager, to: :director

def director
  @director ||= Card::ActManager.fetch self
end

def identify_action
  @action =
    if trash && trash_changed?
      :delete
    elsif new_card?
      :create
    else
      :update
    end
end
