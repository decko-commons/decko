format :html do
  view :read_form do
    edit_field_configs.map do |field, args|
      args[:view] = :read_formgroup
      nest field, args
    end
  end

  view :read_formgroup, template: :haml, unknown: true, wrap: :slot

  # a formgroup has a label (with helptext) and an input
  def formgroup title, opts={}, &block
    input = opts[:input]
    wrap_with :div, formgroup_div_args(opts[:class]) do
      [formgroup_label(input, title, opts[:help]),
       editor_wrap(input, &block)]
    end
  end

  def formgroup_label input, title, help
    parts = [formgroup_title(title), formgroup_help(help)].compact
    return unless parts.present?

    form.label (input || :content), raw(parts.join("\n"))
  end

  def formgroup_title title
    title if voo&.show?(:title) && title.present?
  end

  def formgroup_div_args html_class
    div_args = { class: ["form-group", html_class].compact.join(" ") }
    div_args[:card_id] = card.id if card.real?
    div_args[:card_name] = h card.name if card.name.present?
    div_args
  end

  def formgroup_help text=nil
    return unless voo&.show?(:help) && text != false

    class_up "help-text", "help-block"
    formgroup_voo_help text
    _render_help
  end

  def formgroup_voo_help text
    voo.help = text if voo && text.present? && text.to_s != "true"
  end
end
