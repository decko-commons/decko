
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
  def nested_fields content=nil
    result = []
    each_nested_card(content, true) do |chunk|
      result << [chunk.referee_name, chunk.options]
    end
    result
  end

  def nested_field_cards content=nil
    nested_fields(content).map do |name, _options|
      Card.fetch name
    end
  end

  def nested_cards_for_edit fields_only=false
    return normalized_edit_fields if edit_fields.present?
    result = []
    each_nested_card nil, fields_only do |chunk|
      result << [chunk.options[:nest_name], chunk.options]
    end
    result
  end

  def edit_fields
    voo.edit_structure || []
  end

  def normalized_edit_fields
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

  def process_field chunk, processed
    return unless process_unique_field? chunk, processed
    yield chunk if block_given?
  end

  def each_nested_field content=nil, &block
    each_nested_card content, true, &block
  end

  def each_nested_card content=nil, fields_only=false, &block
    processed = process_tally
    nest_chunks(content).each do |chunk|
      next if fields_only && !field_chunk?(chunk)
      process_nested_chunk chunk, processed, &block
    end
  end

  def uniq_nested_cards content: nil
    with_unique_chunks do
      nest_chunks(content).map do |chunk|
        chunk.referee_card if unique_chunk? chunk
      end
    end
  end

  def nest_chunks content=nil
    content ||= _render_raw
    card.nest_chunks content
  end

  def process_tally
    ::Set.new [card.key]
  end

  def field_chunk? chunk
    chunk.referee_name.to_name.field_of? card.name
  end

  def unique_chunk? chunk
    key = chunk.referee_name.key
    return false if @processed.include? key
    @processed << key
    true
  end

  def with_unique_chunks
    @processed = ::Set.new [card.key]
    yield
  end

  def process_nested_chunk chunk, processed, &block
    virtual = chunk.referee_card&.virtual?
    # TODO: handle structures that are non-virtual
    method = virtual ? :process_virtual_field : :process_field
    send method, chunk, processed, &block
  end

  def process_virtual_field chunk, processed, &block
    return unless process_unique_field? chunk, processed
    subformat(chunk.referee_card).each_nested_field do |sub_chunk|
      process_field sub_chunk, processed, &block
    end
  end

  def process_unique_field? chunk, processed
    key = chunk.referee_name.key
    return false if processed.include? key
    processed << key
    true
  end
end
