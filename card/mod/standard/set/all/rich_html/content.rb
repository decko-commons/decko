def show_comment_box_in_related?
  false
end

def help_rule_card
  setting = new_card? ? [:add_help, { fallback: :help }] : :help
  help_card = rule_card(*setting)
  help_card if help_card&.ok?(:read)
end

format :html do
  def prepare_content_slot
    class_up "card-slot", "d0-card-content"
    voo.hide :menu
  end

  before(:content) { prepare_content_slot }

  view :content do
    wrap { [_render_menu, _render_core] }
  end

  view :short_content, wrap: { div: { class: "text-muted" } } do
    short_content
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

  view :titled, tags: :comment do
    @content_body = true
    wrap do
      [
        _render_header,
        wrap_body { _render_titled_content },
        render_comment_box
      ]
    end
  end

  view :labeled, tags: :unknown_ok do
    @content_body = true
    wrap(true, class: "row") do
      labeled(render_title, wrap_body { "#{render_menu}#{render_labeled_content}" } )
    end
  end

  def labeled label, content
    haml :labeled, label: label, content: content
  end

  view :open, tags: :comment do
    toggle_logic
    @toggle_mode = :open
    @content_body = true
    frame do
      [_render_open_content, render_comment_box]
    end
  end

  view :closed do
    with_nest_mode :closed do
      toggle_logic
      voo.hide :closed_content
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

  def short_content
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
end
