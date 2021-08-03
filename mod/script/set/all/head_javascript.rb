format :html do
  def views_in_head
    super + %w[
      decko_script_variables
      head_javascript
      html5shiv_tag
      script_config_and_initiation
    ]
  end

  view :decko_script_variables, unknown: true, cache: :never, perms: :none do
    javascript_tag do
      decko_script_variables.each_with_object("") do |(k, v), string|
        string << "#{k}=#{script_variable_to_js v};\n"
      end
    end
  end

  view :head_javascript, unknown: true, cache: :never, perms: :none do
    Array.wrap(head_javascript_paths).reject(&:empty?).join("\n")
  end

  view :html5shiv_tag, unknown: true, perms: :none do
    nest :script_html5shiv_printshiv, view: :script_tag
  end

  view :script_config_and_initiation, unknown: true, perms: :none do
    javascript_tag do
      (mod_js_configs << trigger_slot_ready).join "\n\n"
    end
  end

  view :javascript_include_tag, unknown: true, perms: :none do
    "\n<!-- javascript_include_tag not overridden for #{card.name} -->\n"
  end

  def decko_script_variables
    {
      "window.decko": { rootUrl: card_url("") },
      "decko.doubleClick": Card.config.double_click,
      "decko.cssPath": head_stylesheet_path,
      "decko.currentUserId": (Auth.current_id if Auth.signed_in?)
    }
  end

  def head_javascript_paths
    return unless (asset_card = param_or_rule_card :script)

    asset_card.item_cards.map do |script|
      script.format(:html).render :javascript_include_tag
    end
  end

  private

  def trigger_slot_ready
    "$('document').ready(function() { $('.card-slot').trigger('slotReady'); })"
  end

  def script_variable_to_js value
    return "'#{value}'" unless value.is_a? Hash

    vars = value.each_with_object("") do |(k, v), string|
      string << "#{k}: #{script_variable_to_js v}"
    end
    "{ #{vars} }"
  end

  def mod_js_configs
    mod_js_config.map do |codename, js_decko_function|
      config_json = escape_javascript Card::Rule.global_setting(codename)
      "decko.#{js_decko_function}('#{config_json}')"
    end
  end
end
