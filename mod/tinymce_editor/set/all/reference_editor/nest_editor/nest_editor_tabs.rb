format :html do
  def nest_editor_tabs
    tab_hash = {}
    tab_hash[:content] = nest_content_tab if voo.show? :content_tab
    tab_hash.merge! view: haml(:_basics, snippet: nest_snippet),
                    options: haml(:_options, snippet: nest_snippet),
                    rules: nest_rules_tab
    tabs tab_hash, default_active_tab
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