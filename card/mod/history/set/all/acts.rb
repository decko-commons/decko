def act_card?
  self == Card::ActManager.act_card
end

event :finalize_act, after: :finalize_action, when: :act_card? do
  Card::ActManager.act.update_attributes! card_id: id
end

event :remove_empty_act, :integrate_with_delay_final, when: :remove_empty_act? do
  # Card::ActManager.act.delete
  # Card::ActManager.act = nil
end

def remove_empty_act?
  act_card? && ActManager.act&.ar_actions&.reload&.empty?
end
