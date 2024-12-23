format :html do
  # Does two main things:
  # (1) gives CSS classes for styling and
  # (2) adds card data for javascript - including the "card-slot" class,
  #     which in principle is not supposed to be in styles
  def wrap slot=true, slot_attr={}, tag=:div, &block
    attrib = slot_attributes slot, slot_attr
    method_wrap :wrap_with, tag, attrib, &block
  end

  wrapper :slot do |opts|
    attrib = slot_attributes true, opts
    method_wrap(:wrap_with, :div, attrib) { interior }
  end

  def haml_wrap slot=true, slot_attr={}, tag=:div, &block
    attrib = slot_attributes slot, slot_attr
    method_wrap :haml_tag, tag, attrib, &block
  end

  def method_wrap method, tag, attrib, &block
    @slot_view = @current_view
    debug_slot { send method, tag, attrib, &block }
  end

  def slot_attributes slot, slot_attr
    { id: slot_id, class: wrap_classes(slot), data: wrap_data(true) }.tap do |hash|
      add_class hash, slot_attr.delete(:class)
      hash.deep_merge! slot_attr
    end
  end

  def slot_id
    "#{card.name.safe_key}-#{@current_view}-view"
  end

  def wrap_data slot=false
    with_slot_data slot do
      {
        "card-id": card.id,
        "card-name": slot_cardname,
        "card-type-id": card.type_id,
        "card-type-name": card.type_name,
        "card-link-name": card.name.url_key,
        "slot-id": SecureRandom.hex(10)
      }
    end
  end

  def slot_cardname
    name = card.name
    name = name.url_key if card.new? && name.compound?
    h name
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

  def debug_slot &block
    debug_slot? ? debug_slot_wrap(&block) : yield
  end

  def debug_slot?
    params[:debug] == "slot"
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

  def wrap_body &block
    wrap_with(:div, class: body_css_classes, &block)
  end

  def haml_wrap_body &block
    wrap_body do
      capture_haml(&block)
    end
  end

  def body_css_classes
    css_classes = ["d0-card-body"]
    css_classes << "d0-card-content" if @content_body
    css_classes << card.safe_set_keys if @content_body || @set_keys
    classy(*css_classes)
  end

  def wrap_main
    return yield if no_main_wrap?

    wrap_with :div, yield, id: "main"
  end

  def no_main_wrap?
    Env.ajax? || params[:layout] == "none"
  end

  def wrap_with tag, content_or_args={}, html_args={}, &block
    tag_args = block_given? ? content_or_args : html_args
    content_tag(tag, tag_args) { content_within_wrap content_or_args, &block }
  end

  def wrap_each_with tag, content_or_args={}, args={}, &block
    tag_args = block_given? ? content_or_args : args
    content_items_within_wrap(content_or_args, args, &block).map do |item|
      wrap_with(tag, tag_args) { item }
    end.join "\n"
  end

  private

  def content_items_within_wrap content, args
    content = yield(args) if block_given?
    content.compact
  end

  def content_within_wrap content
    content = yield if block_given?
    output(content).to_s.html_safe
  end

  def html_escape_except_quotes string
    # to be used inside single quotes (makes for readable json attributes)
    string.to_s.gsub("&",  "&amp;")
          .gsub("'", "&apos;")
          .gsub(">",  "&gt;")
          .gsub("<",  "&lt;")
  end

  wrapper :div, :div
  wrapper :em, :em

  wrapper :none do
    interior
  end
end
