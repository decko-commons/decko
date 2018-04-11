format :html do
  view :core, cache: :never do
    escape_in_main do
      nest root.card, view: :head
    end
  end

  def escape_in_main
    main? ? (h yield) : yield
  end
end
