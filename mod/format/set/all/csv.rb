require "csv"

format :csv do
  def show view, args
    view ||= :titled
    super view, args
  end

  def nests
    [["_self", { view: :name }], ["_self", { view: :type }]]
  end

  def default_nest_view
    :titled
  end

  def default_item_view
    :name
  end

  view :titled do
    voo.items[:view] ||= :row
    (render_header + render_core).map { |row| CSV.generate_line row }.join
  end

  view :core do
    item_cards.map { |item_card| nest item_card }
  end

  view :row do
    nests.map { |nest_args| nest(*nest_args) }
  end

  # localize
  view :header do
    [%w[Name Type]]
  end

  view :unknown do
    ""
  end
end
