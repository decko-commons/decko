module ClassMethods
  def reset_script_machine
    Auth.as_bot do
      card = Card[:all, :script, :machine_output]
      card.update_columns trash: true
      card.expire
    end
  end

  def reset_all_machines
    Auth.as_bot do
      Card.search(right: { codename: "machine_output" }).each do |card|
        card.update_columns trash: true
        card.expire
      end
      Card::Virtual.where(right_id: MachineCacheID).delete_all
    end
  end
end
