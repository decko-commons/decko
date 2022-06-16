format :html do
  def nest_editor_tabs
    tab_hash = {}
    # tab_hash[:content] = nest_content_tab if voo.show? :content_tab
    tab_hash.merge! view: haml(:_basics, snippet: nest_snippet),
                    options: haml(:_options, snippet: nest_snippet),
                    rules: nest_rules_tab

    tabs tab_hash, default_active_tab, panel_attr: { class: "nest-options" }
  end

  def image_nest_editor_tabs snippet
    # tab_hash[:content] = nest_content_tab if voo.show? :content_tab
    tab_hash = { upload: image_content_tab(snippet),
                 select: haml(:_image_find, snippet: snippet),
                 options: haml(:_image_options, snippet: snippet),
                 preview: image_preview_tab(snippet) }

    class_up "nav", "nav-fill"
    tabs tab_hash, :content, panel_attr: { class: "nest-options" }
  end

  def image_content_tab snippet
    nest(snippet.name, view: :new_image, type: :image, hide: :guide)
  end

  def image_find_tab snippet
    wrap true do
      nest(snippet.name, view: :new_image, type: :image, hide: :guide)
    end
  end

  def image_preview_tab snippet
    wrap true do
      nest(snippet.name, view: :core, type: :image, hide: :guide)
    end
  end

  def show_content_tab?
    !card.is_structure?
  end

  def default_active_tab
    voo.show?(:content_tab) ? :content : :basics
  end

  def nest_content_tab
    name_dependent_slot do
      @nest_content_tab || nest(card.name.field(nest_snippet.name),
                                view: :nest_content, hide: :guide)
    end
  end

  def nest_rules_tab
    name_dependent_slot do
      nest(set_name_for_nest_rules, view: :nest_rules)
    end
  end
end
