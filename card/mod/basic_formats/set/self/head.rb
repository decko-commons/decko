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
      script_rule,
      ie9,
      mod_configs,
      trigger_slot_ready,
      google_analytics,
      # recaptcha
    ]
  end

  def favicon
    return "" unless favicon_code
    %(<link rel="shortcut icon" href="#{nest favicon_code, view: :source, size: :small}" />)
  end

  def favicon_code
    @favicon_code ||=
      %i[favicon logo].find do |name|
        icon_card = Card[name]
        icon_card.type_id == ImageID && !icon_card.db_content.blank?
      end
  end


end
