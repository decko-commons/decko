format :html do
  def prepare_content_slot
    class_up "card-slot", "d0-card-content"
    voo.hide :menu
  end

  before(:content) { prepare_content_slot }

  view :content do
    voo.hide :edit_button
    wrap do
      [_render_menu, _render_core, _render_edit_button(edit: :inline)]
    end
  end

  before(:content_with_edit_button) do
    prepare_content_slot
  end

  view :content_with_edit_button do
    wrap do
      [_render_menu, _render_core, _render_edit_button(edit: :inline)]
    end
  end

  view :short_content, wrap: { div: { class: "text-muted" } } do
    short_content
  end

  view :raw_one_line_content, unknown: :mini_unknown,
                              wrap: { div: { class: "text-muted" } } do
    raw_one_line_content
  end

  view :one_line_content, unknown: :mini_unknown,
                          wrap: { div: { class: "text-muted" } } do
    one_line_content
  end

  before(:content_with_title) { prepare_content_slot }

  view :content_with_title do
    wrap true, title: card.format(:text).render_core do
      [_render_menu, _render_core]
    end
  end

  before :content_panel do
    prepare_content_slot
    class_up "card-slot", "card"
  end

  view :content_panel do
    wrap do
      wrap_with :div, class: "card-body" do
        [_render_menu, _render_core]
      end
    end
  end

  view :titled do
    @content_body = true
    wrap do
      [
        naming { render_header },
        render_flash,
        wrap_body { render_titled_content },
        render_comment_box(optional: :hide)
      ]
    end
  end

  view :labeled, unknown: true do
    @content_body = true
    wrap(true, class: "row") do
      labeled(render_title, wrap_body { "#{render_menu}#{render_labeled_content}" } )
    end
  end

  def labeled label, content
    haml :labeled, label: label, content: content
  end

  def labeled_field field, item_view=:name, opts={}
    opts[:title] ||= Card.fetch_name field
    field_nest field, opts.merge(view: :labeled,
                                 items: (opts[:items] || {}).merge(view: item_view))
  end

  view :open do
    toggle_logic
    @toggle_mode = :open
    @content_body = true
    frame do
      [_render_open_content, render_comment_box(optional: :hide)]
    end
  end

  view :closed do
    with_nest_mode :compact do
      toggle_logic
      class_up "d0-card-body", "closed-content"
      @content_body = false
      @toggle_mode = :close
      frame
    end
  end

  def toggle_logic
    show_view?(:title_link, :hide) ? voo.show(:icon_toggle) : voo.show(:title_toggle)
  end

  def current_set_card
    set_name = params[:current_set]
    set_name ||= "#{card.name}+*type" if card.known? && card.type_id == Card::CardtypeID
    set_name ||= "#{card.name}+*self"
    Card.fetch(set_name)
  end

  def raw_one_line_content
    cleaned = Card::Content.clean! render_raw, {}
    cut_with_ellipsis cleaned
  end

  def one_line_content
    # TODO: use a version of Card::Content.smart_truncate
    #       that counts characters instead of clean!
    cleaned = Card::Content.clean! render_core, {}
    cut_with_ellipsis cleaned
  end

  # LOCALIZE
  def short_content
    short_content_items || short_content_fields || short_content_from_core
  end

  def short_content_items
    return unless card.respond_to? :count
    "#{count} #{'item'.pluralize count}"
  end

  def short_content_fields
    when_rendering_short_content_fields do |num_fields|
      "#{num_fields} #{'field'.pluralize num_fields}"
    end
  end

  def when_rendering_short_content_fields
    return unless voo.structure || card.structure
    return unless (num_fields = nested_field_names.size)&.positive?

    yield num_fields
  end

  def short_content_from_core
    content = render_core
    if content.blank?
      "empty"
    elsif content.size <= 5
      content
    elsif content.count("\n") < 2
      "#{content.size} characters"
    else
      "#{content.count("\n") + 1} lines"
    end
  end

  def count
    @count ||= card.count
  end
end
