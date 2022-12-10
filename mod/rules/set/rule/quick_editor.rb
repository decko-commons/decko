 format :html do
  view :quick_edit, unknown: true, wrap: :slot do
    quick_edit
  end

  view :quick_edit_success do
    set_info true
  end

  def quick_edit
    haml :quick_edit
  end

  def quick_form
    card_form :update, quick_form_opts do
      quick_editor
    end
  end

  def quick_form_opts
    { "data-slot-selector": ".set-info.card-slot",
      success: { view: :quick_edit_success } }
  end

  def set_info notify_change=nil
    wrap true, class: "set-info" do
      haml :set_info, notify_change: notify_change
    end
  end

  def undo_button
    link_to "undo", method: :post, rel: "nofollow", remote: true,
                    class: "btn btn-secondary ms-2 btn-sm btn-reduced-padding slotter",
                    "data-slot-selector": ".card-slot.quick_edit-view",
                    path: { action: :update,
                            revert_actions: [card.last_action_id],
                            revert_to: :previous }
  end
end
