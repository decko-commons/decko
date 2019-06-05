include_set Abstract::Media
include_set Abstract::BsBadge

format :html do
  before :box do
    voo.show! :customize_button, :box_middle
  end

  view :closed_content do
    ""
  end

  view :bar_left do
    class_up "card-title", "my-0 ml-2"
    class_up "media-left", "m-0"
    text_with_image size: :medium, title: "", text: _render_title,
                    media_opts: { class: "align-items-center" }
    # field_nest(:image, view: :core) + wrap_with(:h4, render(:title))
  end

  view :bar_right do
    customize_button text: "Customize"
  end

  view :bar_bottom do
    wrap_with :code do
      render_core
    end
  end
end
