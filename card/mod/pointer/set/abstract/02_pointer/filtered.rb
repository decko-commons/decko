
format :html do
  view :filtered_list, tags: :unknown_ok do
    with_nest_mode :normal do
      class_up "card-slot", editor_id
      wrap do
        haml :filtered_list_input
      end
    end
  end

  def filtered_list_input
    _render_filtered_list
  end

  def filtered_list_item item_card
    nest_item item_card do |rendered, item_view|
      wrap_item rendered, item_view
    end
  end

  # for override
  # @return [Card] search card on which filtering is based
  def filter_card
    filter_card_from_params || default_filter_card
  end

  def default_filter_card
    fcard = card.options_rule_card || Card[:all]
    return fcard if fcard.respond_to? :wql_hash
    fcard.fetch trait: :referred_to_by, new: {}
  end

  def filter_card_from_params
    return unless params[:filter_card]
    Card.fetch params[:filter_card], new: {}
  end

  view :filter_items, tags: :unknown_ok do
    wrap do
      haml :filter_items
    end
  end

  # currently actually used as a class
  # (because we don't have api to override slot's id)
  def editor_id
    @editor_id ||= "editor#{unique_id}"
  end
end
