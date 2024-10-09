format :html do
  # script_calls basket is a hash where
  #  - key is the name of a javascript method
  #  - value is the argument to send to the method
  basket[:script_calls] = {}

  basket[:head_views] += %w[head_javascript script_variables script_calls]

  view :script_variables, unknown: true, cache: :never, perms: :none do
    javascript_tag do
      decko_script_variables.each_with_object("") do |(k, v), string|
        string << "#{k}=#{script_variable_to_js v};\n"
      end
    end
  end

  view :head_javascript, unknown: true, cache: :never, perms: :none do
    Array.wrap(head_javascript_paths).reject(&:empty?).join
  end

  view :script_calls, unknown: true, perms: :none do
    javascript_tag { (script_configs << trigger_slot_ready).join "\n\n" }
  end

  view :javascript_include_tag, cache: :never, unknown: true, perms: :none do
    "\n<!-- javascript_include_tag not overridden for #{card.name} -->\n"
  end

  def decko_script_variables
    {
      "decko.rootUrl": card_url(""),
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
    "$('document').ready(function() { $('.card-slot').trigger('decko.slot.ready'); })"
  end

  def script_variable_to_js value
    return "'#{value}'" unless value.is_a? Hash

    vars = value.each_with_object("") do |(k, v), string|
      string << "#{k}: #{script_variable_to_js v}"
    end
    "{ #{vars} }"
  end

  def script_configs
    basket[:script_calls].map do |js_function, ruby_method|
      "decko.#{js_function}('#{escape_javascript send(ruby_method)}')"
    end
  end

  def javascript_include_tag *args
    "\n<!-- #{card.name} -->#{super}"
  end
end
