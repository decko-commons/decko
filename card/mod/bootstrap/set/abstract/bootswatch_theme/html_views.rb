include_set Abstract::Media
include_set Abstract::BsBadge

format :html do
  view :bar_left do
    class_up "card-title", "mb-0"
    text_with_image size: :small
    # field_nest(:image, view: :core) + wrap_with(:h4, render(:title))
  end

  view :bar_right do
    customize_button
  end

  view :bar_bottom do
    wrap_with :code do
      render_core
    end
    # listing(card.input_names.map { |n| Card.fetch(n) }).join
  end
end