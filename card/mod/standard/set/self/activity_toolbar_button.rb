include_set Abstract::ToolbarSplitButton

format :html do
  view :core, cache: :never do
    subject.toolbar_split_button "activity", view: :history, icon: :history do
      {
        history: (subject._render_history_link if card.history?),
        discussion: subject.link_to_related(:discussion, "discuss", class: "dropdown-item"),
        follow:  subject.follow_link(class: "dropdown-item"),
        editors: subject.link_to_related(:editors, "editors", class: "dropdown-item")
      }
    end
  end
end
