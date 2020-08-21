format :html do
  view :core do
    with_nest_mode :template do
      super()
    end
  end
end
