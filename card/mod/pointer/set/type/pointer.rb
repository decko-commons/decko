include_set Abstract::Pointer

format :html do
  view :overview do
    voo.items[:view] = :mini_bar
    render_open
  end
end
