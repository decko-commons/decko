format :html do
  # Does two main things:
  # (1) gives CSS classes for styling and
  # (2) adds card data for javascript - including the "card-slot" class,
  #     which in principle is not supposed to be in styles
  def wrap slot=true, slot_attr={}, &block
    method_wrap :wrap_with, slot, slot_attr, &block
  end

  def haml_wrap slot=true, slot_attr={}, &block
    method_wrap :haml_tag, slot, slot_attr, &block
  end

  def method_wrap method, slot, slot_attr, &block
    @slot_view = @current_view
    debug_slot do
      send method, :div, slot_attributes(slot, slot_attr), &block
    end
  end

  def slot_attributes slot, slot_attr
    { id: card.name.url_key, class: wrap_classes(slot), data: wrap_data }.tap do |hash|
      add_class hash, slot_attr.delete(:class)
      hash.deep_merge! slot_attr
    end
  end

  def wrap_data slot=true
    with_slot_data slot do
      { "card-id": card.id, "card-name": h(card.name) }
    end
  end

  def with_slot_data slot
    hash = yield
    # rails helper convert slot hash to json
    # but haml joins nested keys with a dash
    hash[:slot] = slot_options_json if slot
    hash
  end

  def slot_options_json
    html_escape_except_quotes JSON(slot_options)
  end

  def slot_options
    options = voo ? voo.slot_options : {}
    name_context_slot_option options
    options
  end

  def name_context_slot_option opts
    return unless initial_context_names.present?
    opts[:name_context] = initial_context_names.map(&:key) * ","
  end

  def debug_slot
    debug_slot? ? debug_slot_wrap { yield } : yield
  end

  def debug_slot?
    params[:debug] == "slot" && !tagged(@current_view, :no_wrap_comments)
  end

  def debug_slot_wrap
    pre = "<!--\n\n#{'  ' * depth}"
    post = " SLOT: #{h card.name}\n\n-->"
    [pre, "BEGIN", post, yield, pre, "END", post].join
  end

  def wrap_classes slot
    list = slot ? ["card-slot"] : []
    list += ["#{@current_view}-view", card.safe_set_keys]
    list << "STRUCTURE-#{voo.structure.to_name.key}" if voo&.structure
    classy list
  end

  def wrap_body
    css_classes = ["d0-card-body"]
    css_classes += ["d0-card-content", card.safe_set_keys] if @content_body
    wrap_with :div, class: classy(*css_classes) do
      yield
    end
  end

  def wrap_main
    return yield if Env.ajax? || params[:layout] == "none"
    wrap_with :div, yield, id: "main"
  end

  def wrap_with tag, content_or_args={}, html_args={}
    content = block_given? ? yield : content_or_args
    tag_args = block_given? ? content_or_args : html_args
    content_tag(tag, tag_args) { output(content).to_s.html_safe }
  end

  def wrap_each_with tag, content_or_args={}, args={}
    content = block_given? ? yield(args) : content_or_args
    args    = block_given? ? content_or_args : args
    content.compact.map do |item|
      wrap_with(tag, args) { item }
    end.join "\n"
  end
end
