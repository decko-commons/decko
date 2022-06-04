def standardize_items
  super unless content == "_left"
end

def options_card
  Card[:cards_with_account]
end

format :html do
  view :pointer_core do
    wrap_with :div, pointer_items, class: "pointer-list"
  end

  view :core, cache: :never do
    if card.content == "_left"
      core_inherit_content
    else
      render! :pointer_core
    end
  end

  view :one_line_content, cache: :never do
    render_core items: { view: :link }
  end

  view :input do
    item_names = inheriting? ? [] : card.item_names
    %(
      #{_render_hidden_content_field}
      <div class="perm-editor">
        #{inheritance_checkbox}
        <div class="perm-group perm-vals perm-section">
          <h5 class="text-muted">Groups</h5>
          #{groups item_names}
        </div>

        <div class="perm-indiv perm-vals perm-section">
          <h5 class="text-muted">Individuals</h5>
          #{list_input item_list: item_names, extra_css_class: 'perm-indiv-ul'}
        </div>
      </div>
    )
  end

  private

  def groups item_names
    group_options.map do |option|
      checked = !item_names.delete(option.name).nil?
      icon = icon_tag "open_in_new", "text-muted"
      option_link = link_to_card option.name, icon, target: "decko_role"
      box = check_box_tag "#{option.key}-perm-checkbox",
                          option.name, checked, class: "perm-checkbox-button"
      <<-HTML
        <div class="form-check checkbox">
          <label class="form-check-label">
            #{box} #{option.name} #{option_link}
          </label>
        </div>
      HTML
    end * "\n"
  end

  def group_options
    Auth.as_bot do
      Card.search({ type_id: RoleID, sort_by: "name" }, "roles by name")
    end
  end

  def inheritable?
    @inheritable ||=
      begin
        set_name = card.name.trunk_name
        set_card = Card.fetch(set_name)
        not_set = set_card && set_card.type_id != SetID
        not_set ? false : set_card.inheritable?
      end
  end

  def inheriting?
    @inheriting ||= inheritable? && card.content == "_left"
  end

  def inheritance_checkbox
    return unless inheritable?

    <<-HTML
      <div class="perm-inheritance perm-section">
        #{check_box_tag 'inherit', 'inherit', inheriting?}
        <label>
          #{core_inherit_content}
          #{wrap_with(:a, title: "use left's #{card.name.tag} rule") { '?' }}
        </label>
      </div>
    HTML
  end

  def core_inherit_content
    text = if in_context_of_self_set?
             core_inherit_for_content_for_self_set
           else
             "Inherit from left card"
           end
    %(<span class="inherit-perm">#{text}</span>)
  end

  def in_context_of_self_set?
    return false unless @set_context

    @set_context.to_name.tag_name.key == Card[:self].key
  end

  def core_inherit_for_content_for_self_set
    task = card.tag.codename
    ancestor = Card[@set_context.trunk_name.trunk_name]
    links = ancestor.who_can(task).map do |card_id|
      link_to_card card_id, nil, target: args[:target]
    end * ", "
    "Inherit ( #{links} )"
  rescue StandardError
    "Inherit"
  end
end
