format do
  view :page_title, tags: :unknown_ok do
    [(safe_name if card.name.present?), Card.global_setting(:title)].compact.join " - "
  end
end

format :html do
  # add tuples containing a
  #  - the codename of a card with javascript config (usually in json format)
  #  - the name of a javascript method that handles the config
  basket :mod_js_config

  view :head, tags: :unknown_ok do
    views_in_head.map { |viewname| render viewname }.flatten.compact.join "\n"
  end

  def views_in_head
    %i[meta_tags page_title_tag favicon_tag head_stylesheet
       decko_script_variables head_javascript html5shiv_tag
       script_config_and_initiation
       universal_edit_button rss_links]
  end

  # FIXME: tags not working with `template: :haml`
  view :meta_tags, tags: :unknown_ok do
    haml :meta_tags
  end

  view :html5shiv_tag, tags: :unknown_ok do
    nest :script_html5shiv_printshiv, view: :script_tag
  end

  view :page_title_tag, tags: :unknown_ok do
    content_tag(:title) { render :page_title }
  end

  view :favicon_tag, tags: :unknown_ok do
    nest :favicon, view: :link_tag
  end

  view :universal_edit_button, tags: :unknown_ok, denial: :blank, perms: :update do
    return if card.new?
    tag "link", rel: "alternate", type: "application/x-wiki",
                title: "Edit this page!", href: path(view: :edit)
  end

  # these should render a view of the rule card
  # it would then be safe to cache if combined with param handling
  # (but note that machine clearing would need to reset card cache...)
  view :head_stylesheet, tags: :unknown_ok, cache: :never do
    return unless (href = head_stylesheet_path)
    tag "link", href: href, media: "all", rel: "stylesheet", type: "text/css"
  end

  view :head_javascript, tags: :unknown_ok, cache: :never do
    Array.wrap(head_javascript_paths).map do |path|
      javascript_include_tag path
    end
  end

  view :decko_script_variables, tags: :unknown_ok, cache: :never do
    string = ""
    decko_script_variables.each do |k, v|
      string += "#{k}=#{script_variable_to_js v};\n"
    end
    javascript_tag { string }
  end

  def decko_script_variables
    {
      "window.decko": { rootPath: Card.config.relative_url_root },
      "decko.doubleClick": Card.config.double_click,
      "decko.cssPath": head_stylesheet_path,
      "decko.currentUserId": (Auth.current_id if Auth.signed_in?)

    }
  end

  def script_variable_to_js value
    if value.is_a? Hash
      string = "{"
      value.each { |k, v| string += "#{k}:#{script_variable_to_js v}" }
      string + "}"
    else
      "'#{value}'"
    end
  end

  def param_or_rule_card setting
    if params[setting]
      Card[params[setting]]
    else
      root.card.rule_card setting
    end
  end

  def debug_or_machine_path setting, &block
    return unless (asset_card = param_or_rule_card setting)
    debug_path(setting, asset_card, &block) || asset_card.machine_output_url
  end

  def debug_path setting, asset_card
    return unless params[:debug] == setting.to_s
    yield asset_card
  end

  def head_stylesheet_path
    debug_or_machine_path :style do |style_card|
      path mark: style_card.name, item: :import, format: :css
    end
  end

  def head_javascript_paths
    debug_or_machine_path :script do |script_card|
      script_card.item_cards.map do |script|
        script.format(:js).render :source
      end
    end
  end

  view :script_config_and_initiation, tags: :unknown_ok do
    javascript_tag do
      (mod_js_configs << trigger_slot_ready).join "\n\n"
    end
  end

  def mod_js_configs
    mod_js_config.map do |codename, js_decko_function|
      config_json = escape_javascript Card.global_setting(codename)
      "decko.#{js_decko_function}('#{config_json}')"
    end
  end

  def trigger_slot_ready
    "$('document').ready(function() { $('.card-slot').trigger('slotReady'); })"
  end

  # TODO: move to rss mod
  view :rss_links, tags: :unknown_ok do
    render :rss_link_tag if rss_link?
  end

  def rss_link?
    Card.config.rss_enabled && respond_to?(:rss_link_tag)
  end
end
