format :html do
  view :core, cache: :never do
    escape_in_main do
      nest root.card, view: :head
    end
  end

  def escape_in_main
    main? ? (h yield) : yield
  end


  def head_javascript
    output [
      decko_variables,
      # script_rule,
      ie9,
      mod_configs,
      trigger_slot_ready,
      google_analytics,
      # recaptcha
    ]
  end

end
