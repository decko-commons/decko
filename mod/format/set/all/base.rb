def format opts={}
  opts = { format: opts.to_sym } if [Symbol, String].member? opts.class
  Card::Format.new self, opts
end

format do
  def show view, args
    view ||= :core
    render! view, args.merge(main_nest_options)
  end

  # NAME VIEWS

  view :name, compact: true, perms: :none do
    name_variant safe_name
  end

  def safe_name
    card&.name
  end

  def name_variant name
    voo.variant ? name.to_name.vary(voo.variant) : name
  end

  view(:key,      compact: true, perms: :none) { card.key }
  view(:linkname, compact: true, perms: :none) { card.name.url_key }
  view(:url,      compact: true, perms: :none) { card_url _render_linkname }

  view :url_link, compact: true, perms: :none do
    link_to_resource card_url(_render_linkname)
  end

  view :link, compact: true, perms: :none do
    link_view
  end

  view :nav_link, compact: true, perms: :none do
    link_view class: "nav-link"
  end

  def link_view opts={}
    opts[:known] = card.known?
    specify_type_in_link! opts
    link_to_card card.name, _render_title, opts
  end

  def specify_type_in_link! opts
    return if opts[:known] || !voo.type

    opts[:path] = { card: { type: voo.type } }
  end

  view(:codename, compact: true) { card.codename.to_s }
  view(:id,       compact: true) { card.id            }
  view(:type,     compact: true) { card.type_name     }

  # DATE VIEWS

  view(:created_at, compact: true) { date_view card.created_at }
  view(:updated_at, compact: true) { date_view card.updated_at }
  view(:acted_at,   compact: true) { date_view card.acted_at   }

  def date_view date
    if voo.variant
      date.strftime voo.variant
    else
      time_ago_in_words date
    end
  end

  # CONTENT VIEWS

  view :raw do
    structure_card&.content || _render_blank
  end

  def structure_card
    return nil if voo.structure == true

    voo.structure ? Card[voo.structure] : card
  end

  view :core, compact: true do
    process_content _render_raw
  end

  view :content do
    _render_core
  end

  view :open_content do
    _render_core
  end

  view :one_line_content, compact: true do
    with_nest_mode(:compact) { truncate render_core }
  end

  view :labeled_content, unknown: :mini_unknown do
    render_core
  end

  view :titled_content, unknown: :blank do
    render_core
  end

  view :blank, compact: true, perms: :none do
    ""
  end

  # NOTE: content and open_content may look like they should be aliased to
  # core, but it's important that they render core explicitly so that core view
  # overrides work.  the titled and labeled views below, however, are not
  # intended for frequent override, so this shortcut is fine.

  # NAME + CONTENT VIEWS

  view :titled do
    "#{card.name}\n\n#{_render_core}"
  end
  view :open, :titled

  view :labeled do
    "#{card.name}: #{_render_labeled_content}"
  end
  view :closed, :labeled

  # SPECIAL VIEWS

  # view :array, cache: :never do
  #   card.item_cards(limit: 0).map do |item_card|
  #     nest_item item_card, view: core
  #   end.inspect
  # end
end
