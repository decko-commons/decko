basket[:head_views] =
  %i[page_title_tag meta_tags favicon_tag
     stylesheet_tags
     universal_edit_button rss_links]
# TODO: the last two should be in mods

basket[:cache_seed_names] += [
  %i[all head],
  %i[all style],
  %i[all style asset_output],
  %i[all script],
  %i[script right content_options],
  :noindex
]

def noindex?
  unknown? || :noindex.card.include_item?(name)
end

format do
  view :page_title, unknown: true, perms: :none do
    title_parts = [Card::Rule.global_setting(:title)]
    title_parts.unshift safe_name if card.name.present?
    title_parts.join " - "
  end
end

format :html do
  delegate :noindex?, to: :card

  view :head, unknown: true, perms: :none, cache: :always do
    basket[:head_views].map { |viewname| render viewname }.flatten.compact.join "\n"
  end

  view :meta_tags, unknown: true, perms: :none, template: :haml

  view :page_title_tag, unknown: true, perms: :none do
    content_tag(:title) { render :page_title }
  end

  view :favicon_tag, unknown: true, perms: :none do
    nest :favicon, view: :link_tag
  end

  # TODO: move to mod
  view :universal_edit_button, unknown: :blank, denial: :blank, perms: :update do
    return if card.new?

    tag "link", rel: "alternate", type: "application/x-wiki",
                title: "Edit this page!", href: path(view: :edit)
  end

  # TODO: move to rss mod
  view :rss_links, unknown: true, perms: :none do
    render :rss_link_tag if rss_link?
  end

  # these should render a view of the rule card
  # it would then be safe to cache if combined with param handling
  # (but note that machine clearing would need to reset card cache...)
  view :stylesheet_tags, cache: :never, unknown: true, perms: :none do
    [nest(:style_mods, view: :remote_style_tags), main_stylesheet_tag]
  end

  private

  def main_stylesheet_tag
    @main_stylesheet_tag ||=
      tag "link", media: "all",
                  rel: "stylesheet",
                  type: "text/css",
                  href: main_stylesheet_path
  end

  def main_stylesheet_path
    nest(param_or_rule_card(:style), view: :stylesheet_path)
  end

  def param_or_rule_card setting
    params[setting]&.card || root.card.rule_card(setting)
  end

  def rss_link?
    Card.config.rss_enabled && respond_to?(:rss_link_tag)
  end
end
