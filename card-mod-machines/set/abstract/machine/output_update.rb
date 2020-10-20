def reset_machine_output
  Auth.as_bot do
    moc = machine_output_card
    @updated_at = output_updated_at
    moc.delete! if moc.real?
    update_input_card
    expire_if_source_file_changed @updated_at
  end
end

def regenerate_machine_output
  return unless ok?(:read)
  lock { run_machine }
end

def update_machine_output
  return unless ok?(:read)
  lock do
    update_input_card
    expire_if_source_file_changed output_updated_at
    run_machine
  end
end

def ensure_machine_output
  output = fetch :machine_output
  return if output&.selected_content_action_id
  update_machine_output
end

def update_input_card
  if Card::Director.running_act?
    input_card = attach_subcard! machine_input_card
    input_card.content = ""
    engine_input.each { |input| input_card << input }
  else
    machine_input_card.items = engine_input
  end
end

def input_cards_with_changed_source output_updated
  machine_input_card.extended_item_cards.select do |i_card|
    i_card.try(:source_changed?, since: output_updated)
  end
end

def expire_if_source_file_changed output_updated_at
  return unless output_updated_at
  changed = input_cards_with_changed_source(output_updated_at)
  return if changed.empty?
  changed.each(&:expire_machine_cache)
  true
end

# regenerates the machine output if a source file of a input card has been changed
def update_if_source_file_changed
  return unless expire_if_source_file_changed output_updated_at
  regenerate_machine_output
end

def output_updated_at
  return unless (output_card = machine_output_card)
  if output_card.coded?
    File.mtime output_card.file.path
  else
    output_card.updated_at
  end
end
