format :html do
  view :new, perms: :create, tags: :unknown_ok, cache: :never do
    new_view_frame_and_form new_form_opts
  end

  def new_view_frame_and_form form_opts
    buttons = form_opts.delete(:buttons) || _render_new_buttons
    form_opts = form_opts.reverse_merge(success: new_view_success)

    with_nest_mode :edit do
      voo.title ||= new_view_title if new_name_prompt?
      voo.show :help
      frame_and_form :create, form_opts do
        [
          new_view_hidden,
          new_view_name,
          new_view_type,
          _render_content_formgroup,
          buttons
        ]
      end
    end
  end

  def new_view_hidden
  end

  def new_form_opts
    { "main-success" => "REDIRECT" }
  end

  def new_view_title
    output(
      "New",
      (card.type_name unless card.type_id == Card.default_type_id)
    )
  end

  def new_view_success
    card.rule(:thanks) || "_self"
  end

  # NAME HANDLING

  def new_view_name
    if new_name_prompt?
      new_name_formgroup
    elsif !autoname?
      hidden_field_tag "card[name]", card.name
    end
  end

  def new_name_formgroup
    output _render_name_formgroup,
           hidden_field_tag("name_prompt", true)
  end

  def new_name_prompt?
    voo.visible? :name_formgroup do
      needs_name? || params[:name_prompt]
    end
  end

  def autoname?
    @autoname.nil? ? (@autoname = card.rule_card :autoname).present? : @autoname
  end

  def needs_name?
    card.name.blank? && !autoname?
  end

  # TYPE HANDLING

  def new_view_type
    if new_type_prompt?
      _render_new_type_formgroup
    else
      hidden_field_tag "card[type_id]", card.type_id
    end
  end

  def new_type_prompt?
    voo.visible? :new_type_formgroup do
      !new_type_preset? && new_type_prompt_context? && new_type_permitted?
    end
  end

  def new_type_preset?
    params[:type] || voo.type
  end

  def new_type_prompt_context?
    main? || card.simple? || card.is_template?
  end

  def new_type_permitted?
    Card.new(type_id: card.type_id).ok? :create
  end

  view :new_type_formgroup do
    wrap_type_formgroup do
      type_field class: "type-field live-type-field",
                 href: path(view: :new),
                 "data-remote" => true
    end
  end

  view :new_buttons do
    button_formgroup do
      [standard_create_button, standard_cancel_button(cancel_button_new_args)]
    end
  end

  # path to redirect to after canceling a new form
  def cancel_button_new_args
    href = case
           when main?          then path_to_previous
           when voo&.home_view then path(view: voo.home_view)
           else                     path(view: :missing)
           end
    { href: href }
  end

  def standard_create_button
    submit_button class: "submit-button create-submit-button"
  end
end
