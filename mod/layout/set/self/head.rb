setting_opts group: :webpage, position: 1, rule_type_editable: false,
             short_help_text: "head tag content",
             help_text: "head tag content"

format :html do
  # when *head is rendered in the main body of a page, we escape the HTML
  # otherwise (most typically in the head tag, of course), we render the
  # HTML unescaped
  view :core, cache: :never do
    escape_in_main do
      nest root.card, view: :head
      # NOTE: that the head tag for each card is different
      # (different title, different style rules, etc)
      # so we don't cache the core of *head, but we _do_ cache some
      # views within each head (see all/head.rb)
    end
  end

  view :input do
    "Content can't be edited."
  end

  view :bar_bottom do
    
  end

  def escape_in_main
    main? ? (h yield) : yield
  end
end
