format do
  view :page_title, tags: :unknown_ok do
    [(safe_name if card.name.present?), Card.global_setting(:title)].compact.join " - "
  end
end

format :html do
  view :head, tags: :unknown_ok do
    views_in_head.map { |viewname| render viewname }.flatten.compact.join "\n"
  end

  def views_in_head
    %i[meta_tags page_title_tag favicon head_stylesheet head_javascript
       universal_edit_button rss_links]
  end

  # FIXME: tags not working with `template: :haml`
  view :meta_tags, tags: :unknown_ok do
    haml :meta_tags #template: :haml
  end

  view :page_title_tag, tags: :unknown_ok do
    content_tag(:title) { render :page_title }
  end

  view :favicon_tag, tags: :unknown_ok do
    nest :favicon, view: :link_tag
  end

  view :universal_edit_button, denial: :blank, perms: :update do
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

  view :decko_script_variables, tags: :unknown_ok do

  end

  def decko_script_variables
    {
      "window.decko": "{rootPath:'#{Card.config.relative_url_root}'}",
      "decko.doubleClick": Card.config.double_click,
      "decko.cssPath": head_stylesheet_path
    }
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
