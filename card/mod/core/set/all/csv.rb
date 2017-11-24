format :csv do
  view :core do
    if (item_view_options[:view] == :name_with_fields) && focal?
      title_row("item name") + name_with_field_rows
    else
      super()
    end
  end

  def name_with_field_rows
    return [] unless row_card_names.present?

    row_card_names.map do |item_name|
      CSV.generate_line row_from_field_names(item_name, columns)
    end.join
  end

  def row_card_names
    @row_cards ||= card.item_names
  end

  def columns
    columns = []
    csv_structure_card.format.each_nested_field do |chunk|
      columns << chunk.referee_name.tag
    end
    columns
  end

  def csv_structure_card
    card.rule_card(:csv_structure) || Card.fetch(row_card_names.first)
  end

  def row_from_field_names parent_name, field_names, view=:core
    field_names.each_with_object([parent_name]) do |field, row|
      row << nest([parent_name, field], view: view)
    end
  end

  def title_row extra_titles=nil
    titles = column_titles extra_titles
    return "" unless titles.present?
    CSV.generate_line titles.map(&:upcase)
  end

  def column_titles extra_titles=nil
    res = Array extra_titles
    card1 = Card.fetch card.item_names(limit: 1).first
    card1.each_nested_chunk do |chunk|
      res << column_title(chunk.options)
    end
    res.compact
  end

  def column_title opts
    if opts[:title]
      opts[:title]
    elsif %w[name link].member? opts[:view]
      opts[:view]
    else
      opts[:nest_name].to_name.tag
    end
  end
end
