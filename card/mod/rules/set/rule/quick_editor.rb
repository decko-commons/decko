format :html do
  view :quick_edit, unknown: true, template: :haml, wrap: :slot do
  end

  view :quick_edit_success do
    set_info true
  end

  def quick_form
    card_form :update,
              "data-slot-selector": ".set-info.card-slot",
              success: { view: :quick_edit_success }  do
      quick_editor
    end
  end

  def set_info notify_change=nil
    wrap true, class: "set-info" do
      haml :set_info, notify_change: notify_change
    end
  end

  def undo_button
    link_to "undo", method: :post, rel: "nofollow", class: "btn btn-secondary ml-2 btn-sm btn-reduced-padding slotter",
                    remote: true,
                    "data-slot-selector": ".card-slot.quick_edit-view",
                    path: { action: :update,
                            revert_actions: [card.last_action_id],
                            revert_to: :previous }
  end
end
