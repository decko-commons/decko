format :html do
  def frame
    class_up "d0-card-header", "card-header"
    class_up "d0-card-body", "card-body card-text"
    super
  end

  def standard_frame slot=true
    if panel_state
      class_up "d0-card-frame", "card bg-#{panel_state} text-white"
    else
      class_up "d0-card-frame", "card"
    end
    super
  end

  def panel_state; end
end
