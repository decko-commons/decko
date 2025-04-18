format :html do
  delegate :autoname?, to: :card

  view :new, perms: :create, unknown: true, cache: :never do
    framed_create_form new_form_opts
  end

  view :new_in_modal, perms: :create, unknown: true, cache: :never,
                      wrap: { modal: { footer: "", size: :edit_modal_size,
                                       title: :new_in_modal_title,
                                       menu: :new_modal_menu } } do
    voo.buttons_view ||= :new_in_modal_buttons
    wrap do
      create_form "data-slot-selector": "modal-origin",
                  "data-slot-error-selector": ".card-slot"
    end
  end

  view :simple_new, perms: :create, unknown: true, wrap: :slot, cache: :never do
    create_form
  end

  view :new_fields, perms: :create, unknown: true, cache: :never do
    wrap true, class: "w-100" do
      [
        new_view_hidden,
        new_view_name,
        new_view_type,
        _render_content_formgroups,
        _render(voo.buttons_view || :new_buttons)
      ]
    end
  end

  def with_create_context
    with_nest_mode :edit do
      voo.title ||= new_view_title if new_name_prompt?
      voo.show :help
      yield
    end
  end

  def create_form form_opts={}
    with_create_context do
      card_form :create, form_opts do
        create_form_with_alert_guide
      end
    end
  end

  def new_modal_size
    :large
  end

  def new_modal_menu
    wrap_with_modal_menu do
      [render_close_modal_link, render_board_link]
    end
  end

  def framed_create_form form_opts={}
    form_opts.reverse_merge! success: new_success

    with_create_context do
      frame_and_form :create, form_opts do
        create_form_with_alert_guide
      end
    end
  end

  def create_form_with_alert_guide
    wrap_with :div, class: "d-flex justify-content-between" do
      [_render_new_fields, (alert_guide if voo.show?(:guide))]
    end
  end

  def new_form_opts
    { "data-main-success": JSON(redirect: true) }
  end

  # LOCALIZE
  def new_view_title
    output(
      "New",
      (card.type_name unless card.type_id == Card.default_type_id)
    )
  end

  def new_in_modal_title
    new_name_prompt? ? new_view_title : render_title
  end

  def new_success
    { mark: card.rule(:thanks) || "_self" }
  end

  def new_in_modal_success; end

  def new_view_hidden; end

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
      type_field class: "type-field _live-type-field slotter",
                 href: path(view: :new_fields),
                 "data-remote" => true
    end
  end

  view :new_buttons do
    button_formgroup do
      [standard_create_button, standard_cancel_button(href: cancel_create_path)]
    end
  end

  view :new_in_modal_buttons do
    class_up "button-form-group", "d-flex"
    button_formgroup do
      [standard_save_and_close_button(text: "Submit"), modal_cancel_button]
    end
  end

  # path to redirect to after canceling a new form
  def cancel_create_path
    if main?
      path_to_previous
    else
      path view: voo&.home_view || :unknown
    end
  end

  def standard_create_button args={}
    submit_button args.merge(class: "submit-button create-submit-button")
  end
end
