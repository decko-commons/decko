format :json do
  before :export do
    @export_depth = inherit(:export_depth).to_i + 1
    @exported_keys = inherit(:exported_keys) || ::Set.new
  end

  view :export, cache: :never do
    # avoid loops
    return [] if @export_depth > max_export_depth || @exported_keys.include?(card.key)
    @exported_keys << card.key
    Array.wrap(render_atom).concat(render_export_items).flatten
  end

  def max_export_depth
    Env.params[:max_export_depth].present? ? Env.params[:max_export_depth].to_i : 2
  end

  before :export_items do
    @exported_keys = inherit(:exported_keys) || ::Set.new
  end

  view :export_items, cache: :never do
    valid_items_for_export.map do |item|
      nest item, view: :export
    end
  end

  def items_for_export
    nest_chunks.map do |chunk|
      next if chunk.try :main?
      chunk.referee_card
    end.compact
  end

  def valid_items_for_export
    items_for_export.flatten.reject(&:blank?).uniq.find_all do |card|
      valid_export_card? card
    end
  end

  def valid_export_card? ecard
    ecard.real? && ecard != card && !@exported_keys.include?(ecard.key)
  end
end
