format :html do
  view :source, cache: :never do
    super()
  end

  view :core, cache: :never do
    super()
  end

  view :editor, cache: :never do
    super()
  end
end
