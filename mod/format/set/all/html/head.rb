format do
  view :page_title, unknown: true, perms: :none do
    title_parts = [Card::Rule.global_setting(:title)]
    title_parts.unshift safe_name if card.name.present?
    title_parts.join " - "
  end
end

format :html do
  view :head, unknown: true, perms: :none do
    views_in_head.map { |viewname| render viewname }.flatten.compact.join "\n"
  end

  def views_in_head
    %i[meta_tags page_title_tag favicon_tag head_stylesheet
       universal_edit_button rss_links]
  end

  # FIXME: tags not working with `template: :haml`
  view :meta_tags, unknown: true, perms: :none do
    haml :meta_tags
  end

  view :page_title_tag, unknown: true, perms: :none do
    content_tag(:title) { render :page_title }
  end

  view :favicon_tag, unknown: true, perms: :none do
    nest :favicon, view: :link_tag
  end

  view :universal_edit_button, unknown: true, denial: :blank, perms: :update do
    return if card.new?

    tag "link", rel: "alternate", type: "application/x-wiki",
                title: "Edit this page!", href: path(view: :edit)
  end

  # these should render a view of the rule card
  # it would then be safe to cache if combined with param handling
  # (but note that machine clearing would need to reset card cache...)
  view :head_stylesheet, unknown: true, cache: :never, perms: :none do
    return unless (href = head_stylesheet_path)

    tag "link", href: href, media: "all", rel: "stylesheet", type: "text/css"
  end

  def param_or_rule_card setting
    if params[setting]
      Card[params[setting]]
    else
      root.card.rule_card setting
    end
  end

  def debug_or_machine_path setting, debug_lambda, machine_path_lambda
    return unless (asset_card = param_or_rule_card setting)
    debug_path(setting, asset_card, &debug_lambda) ||
      machine_path_lambda.call(asset_card.asset_output_url)
  end

  def debug_path setting, asset_card
    return unless params[:debug] == setting.to_s

    yield asset_card
  end

  # TODO: move to rss mod
  view :rss_links, unknown: true, perms: :none do
    render :rss_link_tag if rss_link?
  end

  def rss_link?
    Card.config.rss_enabled && respond_to?(:rss_link_tag)
  end

  def head_stylesheet_path
    debug_or_machine_path(
      :style,
      ->(style_card) { path mark: style_card.name, item: :import, format: :css },
      ->(machine_path) { machine_path }
    )
  end
end
