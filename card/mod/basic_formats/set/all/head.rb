format do
  view :page_title, tags: :unknown_ok do
    [(safe_name if card.name.present?), Card.global_setting(:title)].compact.join " - "
  end
end

format :html do
  view :head, tags: :unknown_ok do
    head_views.map { |viewname| render viewname }.flatten.compact.join "\n"
  end

  def head_views
    %i[meta_tags page_title_tag head_stylesheet head_javascript
       universal_edit_button rss_links]
  end

  view :meta_tags, tags: :unknown_ok, template: :haml

  view :page_title_tag, tags: :unknown_ok do
    content_tag(:title) { render :page_title }
  end

  view :universal_edit_button, denial: :blank, perms: :update do
    return if card.new?
    tag "link", rel: "alternate", type: "application/x-wiki",
                title: "Edit this page!", href: path(view: :edit)
  end

  view :head_stylesheet, tag: :unknown_ok do
    return unless (href = head_stylesheet_path)
    tag "link", href: href, media: "all", rel: "stylesheet", type: "text/css"
  end

  view :head_javascript, tag: :unknown_ok do
    Array.wrap(head_javascript_paths).map do |path|
      javascript_include_tag path
    end
  end

  def param_or_rule_card setting
    if params[setting]
      Card[params[setting]]
    else
      root.card.rule_card setting
    end
  end

  def output_url_or_debug setting
    return unless (asset_card = param_or_rule_card setting)
    params[:debug] == setting.to_s ? yield : asset_card.machine_output_url
  end

  def head_stylesheet_path
    output_url_or_debug :style do |style_card|
      page_path style_card.name, item: :import, format: :css
    end
  end

  def head_javascript_paths
    output_url_or_debug :script do |script_card|
      script_card.items.map do |script|
        script.format(:js).render :source
      end
    end
  end

  # TODO: move to rss mod
  view :rss_links, tag: :unknown_ok do
    render :rss_link_tag if rss_link?
  end

  def rss_link?
    Card.config.rss_enabled && respond_to?(:rss_link_tag)
  end
end
