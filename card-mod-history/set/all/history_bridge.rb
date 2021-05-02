format :html do
  view :creator_credit,
       wrap: { div: { class: "text-muted creator-credit" } }, cache: :never do
    return "" unless card.real?
    "Created by #{nest card.creator, view: :link} "\
    "#{time_ago_in_words(card.created_at)} ago"
  end

  view :updated_by, wrap: { div: { class: "text-muted" } } do
    updaters = Card.search(updater_of: { id: card.id }) if card.id
    return "" unless updaters.present?

    links = updater_links updaters, others_target: card.fetch(:editors)
    "Updated by #{links}"
  end

  def acts_bridge_layout acts, context=:bridge
    output [
      _render_creator_credit,
      act_link_list(acts, context),
      act_paging(acts, context)
    ]
  end

  def act_link_list acts, context
    items = acts_for_accordion(acts, context) do |act, seq|
      act_link_list_item act, seq, context
    end
    bridge_pills items
  end

  def act_link_list_item act, seq=nil, _context=nil
    opts = act_listing_opts_from_params(seq)
    opts[:slot_class] = "revision-#{act.id} history-slot nav-item"
    act_renderer(:bridge).new(self, act, opts).bridge_link
  end

  def act_list_group acts, context, &block
    list_group acts_for_accordion(acts, context, &block), class: "clear-both"
  end

  view :bridge_act, cache: :never do
    opts = act_listing_opts_from_params(nil)
    act = act_from_context
    ar = act_renderer(:bridge).new(self, act, opts)
    class_up "action-list", "my-3"
    wrap_with_overlay title: ar.overlay_title, slot: breadcrumb_data("History") do
      act_listing(act, opts[:act_seq], :bridge)
    end
  end

  private

  def updater_links updaters, item_view: :link, max_count: 3, others_target: card
    return "" unless updaters.present?

    total = updaters.size
    num_to_show = total > max_count ? max_count - 1 : max_count

    links = links_to_updaters(updaters, num_to_show, item_view) +
      link_to_other_updaters(total, others_target, num_to_show)

    links.to_sentence
  end

  def links_to_updaters updaters, num_to_show, item_view
    updaters[0..(num_to_show - 1)].map { |c| nest c, view: item_view }
  end

  def link_to_other_updaters total, target, num_to_show
    return [] unless total > num_to_show

    link_to_card target, "#{total - num_to_show} others"
  end
end
