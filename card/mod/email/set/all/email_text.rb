
format :email_text do
  view :missing do
    ""
  end

  view :compact_missing do
    ""
  end

  view :last_action, perms: :none, cache: :never do
    _render_last_action_verb
  end
end
