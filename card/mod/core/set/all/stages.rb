attr_writer :director
delegate :act_manager, to: :director

def director
  @director ||= Card::ActManager.fetch self
end

def identify_action explicit_delete=false
  @action =
    if explicit_delete || (trash && trash_changed?)
      :delete
    elsif new_card?
      :create
    else
      :update
    end
end
