format :json do
  # returns an array of Hashes (each in export_item view)
  view :export, cache: :never do
    exporting_uniques do
      Array.wrap(render_export_item).concat(export_items_in_view(:export)).flatten
    end
  end

  def max_export_depth
    Env.params[:max_export_depth].present? ? Env.params[:max_export_depth].to_i : 2
  end

  # returns an array of Hashes (each in export_item view)
  view :export_items, cache: :never do
    exporting_uniques do
      export_items_in_view(:export).flatten
    end
  end

  # returns Hash with the essentials needed to import a card into a new database
  view :export_item do
    item = { name: card.name, type: card.type_name, content: card.content }
    item[:codename] = card.codename if card.codename
    track_exporting card
    item
  end

  def export_items_in_view view
    within_max_depth do
      valid_items_for_export.map do |item|
        nest item, view: view
      end
    end
  end

  def track_exporting card
    return unless @exported_keys
    @exported_keys << card.key
  end

  def exporting_uniques
    @exported_keys ||= inherit(:exported_keys) || ::Set.new
    yield
  end

  # prevent recursion
  def within_max_depth
    @export_depth ||= inherit(:export_depth).to_i + 1
    @export_depth > max_export_depth ? [] : yield
  end

  def items_for_export
    nest_chunks.map do |chunk|
      next if main_nest_chunk? chunk
      chunk.referee_card
    end.compact
  end

  def valid_items_for_export
    items_for_export.flatten.reject(&:blank?).uniq.find_all do |card|
      valid_export_card? card
    end
  end

  def valid_export_card? ecard
    ecard.real? && !@exported_keys.include?(ecard.key)
  end

  def main_nest_chunk? chunk
    chunk_nest_name(chunk) == "_main"
  end

  def chunk_nest_name chunk
    return unless chunk.respond_to? :options
    chunk.options&.dig :nest_name
  end
end
