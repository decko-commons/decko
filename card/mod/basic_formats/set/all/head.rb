format do
  view :page_title, tag: :unknown_ok do
    [(safe_name if card.name.present?), Card.global_setting(:title)].compact.join " - "
  end
end

format :html do
  view :head_core, tag: :unknown_ok, template: :haml

  view :universal_edit_button, denial: :blank, perms: :update do
    return "" if card.new?
    tag "link", rel: "alternate", type: "application/x-wiki",
                title: "Edit this page!", href: { path: { view: :edit} }
  end

  view :head_stylesheet, tag: :unknown_ok do
    tag "link", href: style_path, media: "all", rel: "stylesheet", type: "text/css"
  end

  def rss_link?
    Card.config.rss_enabled && respond_to?(:rss_link_tag)
  end

  def param_or_rule_card setting
    if params[setting]
      Card[params[setting]]
    else
      root.card.rule_card setting
    end
  end

  def style_path
    return unless (style_card = param_or_rule_card :style)
    if params[:debug] == "style"
      page_path style_card.name, item: :import, format: :css
    else
      style_card.machine_output_url
    end
  end
end
