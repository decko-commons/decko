# require "truncato"

format :html do
  def prepare_content_slot
    class_up "card-slot", "d0-card-content"
  end

  before(:content) { prepare_content_slot }

  view :content, cache: :yes do
    wrap do
      [
        render_menu(optional: :hide),
        render_core,
        render_edit_button(optional: :hide, edit: :inline)
      ]
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
      [render_menu, render_core]
    end
  end

  before :content_panel do
    prepare_content_slot
    class_up "card-slot", "card"
  end

  view :content_panel do
    wrap do
      wrap_with :div, class: "card-body" do
        [render_menu, render_core]
      end
    end
  end

  view :titled, cache: :yes do
    @content_body = true
    wrap do
      [
        naming { render_header },
        render_flash,
        wrap_body { render_titled_content }
      ]
    end
  end

  # unlike unknown: true, unknown: (same view) can be overridden
  view :labeled, unknown: :labeled, cache: :yes do
    @content_body = true
    wrap(true, class: "row") do
      [labeled(render_title, wrap_body { render_labeled_content }), render_menu]
    end
  end

  def labeled label, content
    haml :labeled, label: label, content: content
  end

  def labeled_field field, item_view=:name, opts={}
    opts[:title] ||= field.cardname
    field_nest field, opts.merge(view: :labeled,
                                 items: (opts[:items] || {}).merge(view: item_view))
  end

  def current_set_card
    set_name = params[:current_set]
    set_name ||= "#{card.name}+*type" if card.known? && card.type_id == Card::CardtypeID
    set_name ||= "#{card.name}+*self"
    Card.fetch(set_name)
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
    with_short_content_fields do |num_fields|
      "#{num_fields} #{'field'.pluralize num_fields}" if num_fields.positive?
    end
  end

  def with_short_content_fields
    yield nested_field_names.size if voo.structure || card.structure
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
