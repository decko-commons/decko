format :html do
  # TODO: raw should be comprised of other views so that it can be cached.
  view :raw, cache: :never do
    output [
      head_meta,
      head_title,
      head_buttons,
      head_stylesheets,
      head_javascript
    ]
  end

  view :core, cache: :never do
    root.first_head? ? _render_raw : CGI.escapeHTML(_render_raw)
  end

  def head_meta
    <<-HTML
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      #{no_index}
    HTML
  end

  def head_title
    title = root.card && root.card.name
    title = nil if title.blank?
    title = params[:action] if title == "*placeholder"
    %(<title>#{title ? "#{title} - " : ''}#{Card.global_setting :title}</title>)
  end

  def head_buttons
    bits = [favicon]
    if root.card
      bits << universal_edit_button
      # RSS # move to mods!
      bits << rss_link
    end
    bits.compact.join "\n      "
  end

  def head_stylesheets
    manual_style = params[:style]
    style_card = Card[manual_style] if manual_style
    style_card ||= root.card.rule_card :style
    @css_path =
      if params[:debug] == "style"
        page_path(style_card.name, item: :import, format: :css)
      elsif style_card
        style_card.machine_output_url
      end
    return unless @css_path
    %(<link href="#{@css_path}" media="all" rel="stylesheet" type="text/css" />)
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

  def no_index
    return unless root.card.unknown?
    '<meta name="robots" content="noindex">'
  end

  def universal_edit_button
    return if root.card.new_record? || !root.card.ok?(:update)
    href = root.path view: :edit
    tag "link", rel: "alternate", type: "application/x-wiki",
                title: "Edit this page!", href: href
  end

  def rss_link
    return unless Card.config.rss_enabled && root.respond_to?(:rss_link_tag)
    root.rss_link_tag
  end
end
