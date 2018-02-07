format :html do
  view :overlay do
    wrap_with :div, class: "alert overlay" do
      _render_core
    end
  end
end
