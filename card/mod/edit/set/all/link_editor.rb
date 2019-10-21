format :html do
  view :link_editor, cache: :never, unknown: true, template: :haml,
                     wrap: { slot: { class: "_overlay d0-card-overlay card nodblclick" } } do
    @link_editor_mode = :overlay
  end

  view :modal_link_editor, cache: :never, unknown: true,
                           wrap: { slot: { class: "nodblclick" } } do
    modal_link_editor
  end


  def nest_rules_editor
    if edit_link.name.blank?
      content_tag :div, "", class: "card-slot" # placeholder
    else
      nest(set_name_for_nest_rules, view: :nest_rules)
    end
  end


  def modal_link_editor
    wrap_with :modal do
      haml :link_editor, link_editor_mode: "modal"
    end
  end

  def edit_nest
    @link_nest ||= LinkParser.new params[:edit_nest]
  end

  def apply_link_data
    data = { "data-tinymce-id": tinymce_id }
    data["data-nest-start".to_sym] = params[:nest_start] if params[:nest_start].present?
    data["data-nest-size".to_sym] = edit_nest.raw.size if params[:edit_nest].present?
    data
  end
end
