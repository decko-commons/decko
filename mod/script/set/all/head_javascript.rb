format :html do
  # script_calls basket is a hash where
  #  - key is the name of a javascript method
  #  - value is the argument to send to the method
  basket[:script_calls] = {}

  basket[:head_views] += %w[javascript_tags script_variables script_calls]

  view :script_variables, unknown: true, cache: :never, perms: :none do
    javascript_tag do
      decko_script_variables.each_with_object("") do |(k, v), string|
        string << "#{k}=#{script_variable_to_js v};\n"
      end
    end
  end

  view :javascript_tags, unknown: true, cache: :deep, perms: :none do
    return unless (asset_card = param_or_rule_card :script)

    [nest(asset_card, view: :remote_script_tags),
     "<!-- MAIN DECKO JAVASCRIPT -->",
     main_javascript_tag(asset_card)]
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
      "decko.cssPath": main_stylesheet_path,
      "decko.currentUserId": (Auth.current_id if Auth.signed_in?)
    }
  end

  def main_javascript_tag asset_card
    javascript_include_tag asset_card.asset_output_url
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
end
