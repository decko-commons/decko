format :json do
  before :export do
    @export_count ? @export_count += 1 : @export_count = 1
    @exported_keys ||= ::Set.new
  end

  view :export, cache: :never do
    # avoid loops
    return [] if @export_count > 5 || @exported_keys.include?(card.key)
    @exported_keys << card.key
    Array.wrap(render_atom).concat(render_export_items).flatten
  end

  before :export_items do
    @exported_keys ||= ::Set.new
  end

  view :export_items, cache: :never do
    valid_items_for_export.map do |item|
      nest item, view: :export
    end
  end

  def items_for_export
    items = []
    card.each_nested_chunk do |chunk|
      next if main_nest_chunk? chunk
      items << chunk.referee_card
    end
    items
  end

  def valid_items_for_export
    items_for_export.flatten.reject(&:blank?).uniq.find_all do |card|
      valid_export_card? card
    end
  end

  def valid_export_card? ecard
    ecard.real? && ecard != card && !@exported_keys.include?(ecard.key)
  end

  def main_nest_chunk? chunk
    chunk_nest_name(chunk) == "_main"
  end

  def chunk_nest_name chunk
    return unless chunk.respond_to? :options
    chunk.options&.dig :nest_name
  end
end
