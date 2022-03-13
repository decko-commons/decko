format :html do
  # alert_types: 'success', 'info', 'warning', 'danger'
  def alert alert_type, dismissable=false, disappear=false, args={}
    add_class args, alert_classes(alert_type, dismissable, disappear)
    wrap_with :div, args.merge(role: "alert") do
      [(alert_close_button if dismissable), output(yield)]
    end
  end

  def alert_classes alert_type, dismissable, disappear
    classes = ["alert", "alert-#{alert_type}"]
    classes << "alert-dismissible " if dismissable
    classes << "_disappear" if disappear
    classy classes
  end

  def alert_close_button
    wrap_with :button, type: "button", "data-bs-dismiss": "alert",
                       class: "btn-close", "aria-label": "Close" do
      wrap_with :span, "&times;", "aria-hidden" => true
    end
  end
end
