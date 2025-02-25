format :html do
  view :creator_credit,
       wrap: { div: { class: "text-muted creator-credit" } }, cache: :never do
    return "" unless card.real?

    "Created by #{nest card.creator, view: :link} " \
      "#{time_ago_in_words(card.created_at)} ago"
  end

  view :updated_by, wrap: { div: { class: "text-muted" } } do
    updaters = Card.search(updater_of: { id: card.id }) if card.id
    return "" unless updaters.present?

    links = updater_links updaters, others_target: card.fetch(:editors)
    "Updated by #{links}"
  end

  view :board_act, cache: :never do
    opts = act_listing_opts_from_params(nil)
    act = act_from_context
    ar = act_renderer(:board).new(self, act, opts)
    class_up "action-list", "my-3"
    wrap_with_overlay title: ar.overlay_title, slot: breadcrumb_data("History") do
      act_listing(act, opts[:act_seq], :board)
    end
  end

  def acts_board_layout acts, context=:board
    output [
      _render_creator_credit,
      act_link_list(acts, context),
      act_paging(acts, context)
    ]
  end

  # not in use?
  # def act_list_group acts, context, &block
  #   list_group acts_for_accordion(acts, context, &block), class: "clear-both"
  # end

  private

  def act_link_list acts, context
    items = acts_for_accordion(acts, context) do |act, seq|
      act_link_list_item act, seq, context
    end
    board_pills items
  end

  def act_link_list_item act, seq=nil, _context=nil
    opts = act_listing_opts_from_params(seq)
    opts[:slot_class] = "revision-#{act.id} history-slot nav-item"
    act_renderer(:board).new(self, act, opts).board_link
  end

  def act_paging acts, context
    return unless controller.request # paginate requires a request

    wrap_with :div, class: "slotter btn-sm" do
      # normally we let method_missing handle the action_view stuff,
      # but that doesn't handle **arguments yet
      action_view.send :paginate, current_page_acts(acts), **act_paging_opts(context)
    end
  end

  def act_paging_opts context
    { remote: true, theme: "twitter-bootstrap-4" }.tap do |opts|
      opts[:total_pages] = 10 if limited_paging? context
    end
  end

  def limited_paging? context
    context == :absolute && Act.count > 1000
  end

  def updater_links updaters, item_view: :link, max_count: 3, others_target: card
    total = updaters.size
    num_to_show = number_of_updaters_to_show total, max_count

    links =
      links_to_updaters(updaters, num_to_show, item_view) +
      link_to_other_updaters(total, others_target, num_to_show)

    links.to_sentence
  end

  def number_of_updaters_to_show total, max_count
    total > max_count ? max_count - 1 : max_count
  end

  def links_to_updaters updaters, num_to_show, item_view
    updaters[0..(num_to_show - 1)].map { |c| nest c, view: item_view }
  end

  def link_to_other_updaters total, target, num_to_show
    return [] unless total > num_to_show

    link_to_card target, "#{total - num_to_show} others"
  end
end
