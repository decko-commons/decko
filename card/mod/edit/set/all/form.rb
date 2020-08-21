format :html do
  # FIELDSET VIEWS

  # sometimes multiple card formgroups, sometimes just one
  view :content_formgroups, cache: :never do
    wrap_with :fieldset, edit_slot, class: classy("card-editor", "editor")
  end

  view :name_formgroup do
    formgroup "Name", input: "name", help: false do
      raw name_field
    end
  end

  # single card content formgroup, labeled with "Content"
  view :content_formgroup, unknown: true, cache: :never do
    wrap_content_formgroup { content_field }
  end

  view :edit_in_form, cache: :never, perms: :update, unknown: true do
    reset_form
    @in_multi_card_editor = true
    edit_slot
  end

  view :conflict_tracker, cache: :never, unknown: true do
    return unless card&.real?

    card.last_action_id_before_edit = card.last_action_id
    hidden_field :last_action_id_before_edit, class: "current_revision_id"
  end

  def wrap_content_formgroup
    formgroup("Content", input: :content, help: false,
                         class: classy("card-editor")) { yield }
  end

  def button_formgroup
    wrap_with :div, class: classy("form-group") do
      wrap_with :div, yield
    end
  end

  def name_field
    # value needed because otherwise gets wrong value if there are updates
    text_field :name, value: card.name, autocomplete: "off"
  end

  def content_field
    with_nest_mode :normal do
      # by changing nest mode to normal, we ensure that editors (eg image
      # previews) can render core views.
      output [_render_conflict_tracker, _render_input]
    end
  end

  # SAMPLE editor view for override
  # view :input do
  #   text_area :content, rows: 5, class: "d0-card-content"
  # end

  def edit_slot
    case
    when inline_nests_editor?  then _render_core
    when multi_card_editor?    then multi_card_edit(true)
    when in_multi_card_editor? then editor_in_multi_card
    else                            single_card_edit_field
    end
  end

  # test: render nests within a normal rendering of the card's content?
  # (as opposed to a standardized form)
  def inline_nests_editor?
    voo.input_type == :inline_nests
  end

  # test: are we opening a new multi-card form?
  def multi_card_editor?
    voo.structure || voo.edit_structure || # structure configured in voo
      card.structure ||                    # structure in card rule
      edit_fields?                         # list of fields in card rule
  end

  # override and return true to optimize
  def edit_fields?
    edit_fields.present?
  end

  # test: are we already within a multi-card form?
  def in_multi_card_editor?
    @in_multi_card_editor.present?
  end

  def single_card_edit_field
    if voo.show?(:type_formgroup) || voo.show?(:name_formgroup)
      _render_content_formgroup # use formgroup for consistency
    else
      editor_wrap(:content) { content_field }
    end
  end

  def editor_in_multi_card
    add_junction_class
    formgroup render_title,
              input: "content", help: true, class: classy("card-editor") do
      [content_field, (form.hidden_field(:type_id) if card.new_card?)]
    end
  end

  def multi_card_edit fields_only=false
    field_configs = edit_field_configs fields_only
    return structure_link if field_configs.empty?

    field_configs.map do |name, options|
      nest name, options || {}
    end.join "\n"
  end

  def structure_link
    # LOCALIZE
    structured = link_to_card card.structure_rule_card, "structured"
    "<label>Content</label>"\
    "<p><em>Uneditable; content is #{structured} without nests</em></p>"
  end

  # @param [Hash|Array] fields either an array with field names and/or field
  # cards or a hash with the fields as keys and a hash with nest options as
  # values
  def process_edit_fields fields
    fields.map do |field, opts|
      field_nest field, opts
    end.join "\n"
  end
  ###

  # If you use subfield cards to render a form for a new card
  # then the subfield cards should be created on the new card not the existing
  # card that build the form

  def form
    @form ||= inherit(:form) || new_form
  end

  def new_form
    @form_root = true unless parent&.form_root
    instantiate_builder(form_prefix, card, {})
  end

  def reset_form
    @form = new_form
  end

  def form_prefix
    case
    when explicit_form_prefix          then explicit_form_prefix # configured
    when simple_form?                  then "card"               # simple form
    when parent.card.name == card.name then parent.form_prefix   # card nests self
    else                                    edit_in_form_prefix
    end
  end

  def simple_form?
    form_root? || !form_root || !parent
  end

  def edit_in_form_prefix
    "#{parent.form_prefix}[subcards][#{card.name.from form_context.card.name}]"
  end

  def explicit_form_prefix
    inherit :explicit_form_prefix
  end

  def form_context
    form_root? || !form_root ? self : parent
  end

  def form_root?
    @form_root == true
  end

  def form_root
    return self if @form_root

    parent ? parent.form_root : nil
  end

  def card_form action, opts={}
    @form_root = true
    hidden = hidden_form_tags action, opts
    form_for card, card_form_opts(action, opts) do |cform|
      @form = cform
      hidden + output(yield(cform))
    end
  end

  def hidden_form_tags _action, opts
    success = opts.delete :success
    success_tags success
  end

  # @param action [Symbol] :create or :update
  # @param opts [Hash] html options
  # @option opts [Boolean] :redirect (false) if true form is no "slotter"
  def card_form_opts action, opts={}
    url, action = card_form_url_and_action action
    html_opts = card_form_html_opts action, opts
    form_opts = { url: url, html: html_opts }
    form_opts[:remote] = true unless html_opts.delete(:redirect)
    form_opts
  end

  def card_form_html_opts action, opts={}
    add_class opts, "card-form"
    add_class opts, "slotter" unless opts[:redirect] || opts[:no_slotter]
    add_class opts, "autosave" if action == :update
    opts
  end

  def card_form_url_and_action action
    case action
    when Symbol then [path(action: action), action]
    when Hash   then [path(action), action[:action]]
      # for when non-action path args are required
    else
      raise Card::Error, "unsupported #card_form_url action: #{action}"
    end
  end

  def editor_wrap type=nil
    html_class = "editor"
    html_class << " #{type}-editor" if type
    wrap_with :div, class: html_class do
      yield
    end
  end

  # FIELD VIEWS

  def add_junction_class
    return unless card.name.junction?

    class_up "card-editor", "RIGHT-#{card.name.tag_name.safe_key}"
  end
end
