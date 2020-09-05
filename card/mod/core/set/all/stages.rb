attr_writer :director
delegate :act_manager, to: :director

def director
  @director ||= Card::ActManager.fetch self
end

def action
  @action ||=
    if trash && trash_changed?
      :delete
    elsif new_card?
      :create
    else
      :update
    end
end
