
def each_chunk opts={}
  content = opts[:content] || self.content
  chunk_type = opts[:chunk_type] || Card::Content::Chunk
  Card::Content.new(content, self).find_chunks(chunk_type).each do |chunk|
    next unless chunk.referee_name # filter commented nests
    yield chunk
  end
end

def each_reference_chunk content=nil
  reference_chunk_type = Card::Content::Chunk::Reference
  each_chunk content: content, chunk_type: reference_chunk_type do |chunk|
    yield chunk
  end
end

def each_nested_chunk content=nil
  nest_chunk_type = Card::Content::Chunk::Nest
  each_chunk content: content, chunk_type: nest_chunk_type do |chunk|
    yield chunk
  end
end

def each_item_name_with_options content=nil
  each_reference_chunk content do |chunk|
    options = chunk.respond_to?(:options) ? chunk.options : {}
    yield chunk.referee_name, options
  end
end


format do
  def nested_fields content=nil
    result = []
    each_nested_card(content) do |chunk|
      result << [chunk.referee_name, chunk.options]
    end
    result
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
    edit_fields.map do |name_or_card, options|
      next [name_or_card, options || {}] if name_or_card.is_a?(Card)
      options ||= Card.fetch_name name_or_card
      options = { title: options } if options.is_a?(String)
      [card.name.field(name_or_card), options]
    end
  end

  def process_field chunk, processed, &_block
    return unless process_unique_field? chunk, processed
    yield chunk
  end

  def each_nested_field content=nil, &block
    each_nested_card content, fields_only=true, &block
  end

  def each_nested_card content=nil, fields_only=true, &block
    processed = ::Set.new [card.key]
    content ||= _render_raw
    card.each_nested_chunk content do |chunk|
      next if fields_only && !field_chunk?(chunk)
      process_nested_chunk chunk, processed, &block
    end
  end

  def field_chunk? chunk
    chunk.referee_name.to_name.field_of? card.name
  end

  def process_nested_chunk chunk, processed, &block
    virtual = chunk.referee_card && chunk.referee_card.virtual?
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