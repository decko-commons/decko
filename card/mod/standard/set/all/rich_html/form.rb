format :html do
  # FIELDSET VIEWS
  view :content_formgroup, cache: :never do
    wrap_with :fieldset, edit_slot, class: classy("card-editor", "editor")
  end

  view :name_formgroup do
    formgroup "name", editor: "name", help: false do
      raw name_field
    end
  end

  view :type_formgroup do
    wrap_type_formgroup do
      type_field class: "type-field edit-type-field"
    end
  end

  view :edit_in_form, cache: :never, perms: :update, tags: :unknown_ok do
    reset_form
    @in_multi_card_editor = true
    edit_slot
  end

  def wrap_type_formgroup
    formgroup "type", editor: "type", class: "type-formgroup", help: false do
      yield
    end
  end

  def button_formgroup
    wrap_with :div, class: "form-group" do
      wrap_with :div, yield
    end
  end

  def name_field
    # value needed because otherwise gets wrong value if there are updates
    text_field :name, value: card.name, autocomplete: "off"
  end

  def type_field args={}
    typelist = Auth.createable_types
    current_type = type_field_current_value args, typelist
    options = options_from_collection_for_select typelist, :to_s, :to_s,
                                                 current_type
    template.select_tag "card[type]", options, args
  end

  def type_field_current_value args, typelist
    return if args.delete :no_current_type
    if !card.new_card? && !typelist.include?(card.type_name)
      # current type should be an option on existing cards,
      # regardless of create perms
      typelist.push(card.type_name).sort!
    end
    card.type_name_or_default
  end

  def content_field skip_rev_id=false
    with_nest_mode :normal do
      # by changing nest mode to normal, we ensure that editors (eg image
      # previews) can render core views.
      output [content_field_revision_tracking(skip_rev_id), _render_editor]
    end
  end

  # SAMPLE editor view for override
  # view :editor do
  #   text_area :content, rows: 5, class: "d0-card-content"
  # end

  def content_field_revision_tracking skip_rev_id
    card.last_action_id_before_edit = card.last_action_id
    return if !card || card.new_card? || skip_rev_id
    hidden_field :last_action_id_before_edit, class: "current_revision_id"
  end

  def edit_slot
    case
    when inline_nests_editor?  then _render_core
    when multi_card_editor?    then multi_card_edit(true)
    when in_multi_card_editor? then editor_in_multi_card
    else                            single_card_edit_field
    end
  end

  # test: render nests within a normal rendering of the card's content? (as opposed to a standardized form)
  def inline_nests_editor?
    voo.editor == :inline_nests
  end

  # test: are we opening a new multi-card form?
  def multi_card_editor?
    nests_editor? ||                         # editor configured in voo
      voo.structure || voo.edit_structure || # structure configured in voo
      card.structure ||                      # structure in card rule
      edit_fields.present?                   # list of fields in card rule
  end

  # test: are we already within a multi-card form?
  def in_multi_card_editor?
    @in_multi_card_editor.present?
  end

  def nests_editor?
    voo.editor == :nests
  end

  def single_card_edit_field
    if voo.show?(:type_formgroup) || voo.show?(:name_formgroup)
      # display content field in formgroup for consistency with other fields
      formgroup("", editor: :content, help: false) { content_field }
    else
      editor_wrap(:content) { content_field }
    end
  end

  def editor_in_multi_card
    add_junction_class
    formgroup render_title,
              editor: "content", help: true, class: classy("card-editor") do
      [content_field, (form.hidden_field(:type_id) if card.new_card?)]
    end
  end

  def multi_card_edit fields_only=false
    nested_cards_for_edit(fields_only).map do |name, options|
      options ||= {}
      options[:hide] = [options[:hide], :toolbar].flatten.compact
      nest name, options
    end.join "\n"
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
    @form ||= begin
      @form_root = true unless parent&.form_root
      instantiate_builder(form_prefix, card, {})
    end
  end

  def reset_form
    @form = nil
    form
  end

  def form_prefix
    case
    when (voo_prefix = form_prefix_from_voo) then voo_prefix         # configured
    when form_root? || !form_root || !parent then "card"             # simple form
    when parent.card == card                 then parent.form_prefix # card nests itself
    else                                          edit_in_form_prefix
    end
  end

  def form_prefix_from_voo
    voo&.live_options&.dig :input_name
  end

  def edit_in_form_prefix
    "#{parent.form_prefix}[subcards][#{card.name.from form_context.card.name}]"
  end

  def form_context
    (form_root? || !form_root) ? self : parent
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
    success = opts.delete(:success)
    form_for card, card_form_opts(action, opts) do |cform|
      @form = cform
      success_tags(success) + output(yield(cform))
    end
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
    add_class opts, "slotter" unless opts[:redirect]
    add_class opts, "autosave" if action == :update
    opts[:recaptcha] ||= "on" if card.recaptcha_on?
    opts.delete :recaptcha if opts[:recaptcha] == :off
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
