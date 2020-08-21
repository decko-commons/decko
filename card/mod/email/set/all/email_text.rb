
format :email_text do
  view :unknown do
    ""
  end

  view :compact_missing do
    ""
  end

  view :last_action, perms: :none, cache: :never do
    _render_last_action_verb
  end
end
