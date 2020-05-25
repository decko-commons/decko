
def chunks content, type, named=false
  content ||= self.content
  type ||= Card::Content::Chunk
  all_chunks = Card::Content.new(content, self).find_chunks type
  named ? all_chunks.select(&:referee_name) : all_chunks
end

def reference_chunks content=nil, named=true
  chunks content, Card::Content::Chunk::Reference, named
end

# named=true rejects commented nests
def nest_chunks content=nil, named=true
  chunks content, Card::Content::Chunk::Nest, named
end

# named=true rejects external links (since the don't refer to a card name)
def link_chunks content=nil, named=false
  chunks content, Card::Content::Chunk::Link, named
end

def each_item_name_with_options content=nil
  reference_chunks(content).each do |chunk|
    options = chunk.respond_to?(:options) ? chunk.options : {}
    yield chunk.referee_name, options
  end
end

format do
  def nest_chunks content=nil
    content ||= _render_raw
    card.nest_chunks content
  end

  def nested_cards content=nil
    nest_chunks(content).map(&:referee_card).uniq
  end

  def edit_fields
    voo.edit_structure || []
  end

  def nested_field_names content=nil
    nest_chunks(content).map(&:referee_name).select { |n| field_name? n }
  end

  def nested_field_cards content=nil
    nested_cards(content).select { |c| field_name? c.name }
  end

  def field_name? name
    name.field_of? card.name
  end

  # @return [Array] of Arrays.  each is [nest_name, nest_options_hash]
  def edit_field_configs fields_only=false
    if edit_fields.present?
      explicit_edit_fields_config # explicitly configured in voo or code
    else
      implicit_edit_fields_config fields_only # inferred from nests
    end
  end

  def implicit_edit_fields_config fields_only
    result = []
    each_nested_chunk(fields: fields_only) do |chunk|
      result << [chunk.options[:nest_name], chunk.options]
    end
    result
  end

  def each_nested_field_chunk &block
    each_nested_chunk fields: true, &block
  end

  def each_nested_chunk content: nil, fields: false, uniq: true, virtual: true, &block
    return unless block_given?
    chunks = prepare_nested_chunks content, fields, uniq
    process_nested_chunks chunks, virtual, &block
  end

  def uniq_chunks chunks
    processed = ::Set.new [card.key]
    chunks.select do |chunk|
      key = chunk.referee_name.key
      ok = !processed.include?(key)
      processed << key
      ok
    end
  end

  def field_chunks chunks
    chunks.select { |chunk| field_name?(chunk.referee_name) }
  end

  private

  def prepare_nested_chunks content, fields, uniq
    chunks = nest_chunks content
    chunks = field_chunks chunks if fields
    chunks = uniq_chunks chunks if uniq
    chunks
  end

  def process_nested_chunks chunks, virtual, &block
    chunks.each do |chunk|
      process_nested_chunk chunk, virtual, &block
    end
  end

  def process_nested_chunk chunk, virtual, &block
    if chunk.referee_card&.virtual?
      process_nested_virtual_chunk chunk, &block unless virtual
    else
      yield chunk
    end
  end

  def process_virtual_chunk chunk
    subformat(chunk.referee_card).each_nested_field_chunk { |sub_chunk| yield sub_chunk }
  end

  def explicit_edit_fields_config
    edit_fields.map do |cardish, options|
      field_mark = normalized_edit_field_mark cardish, options
      options = normalized_edit_field_options options, Card::Name[field_mark]
      [field_mark, options]
    end
  end

  def normalized_edit_field_options options, cardname
    options ||= cardname
    options.is_a?(String) ? { title: options } : options
  end

  def normalized_edit_field_mark cardish, options
    return cardish if cardish.is_a?(Card) ||
                      (options.is_a?(Hash) && options.delete(:absolute))
    card.name.field cardish
  end
end
