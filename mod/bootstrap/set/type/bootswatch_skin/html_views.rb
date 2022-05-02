include_set Abstract::Media
# include_set Abstract::BsBadge

def new_customized_name
  nname = "#{name} customized"
  if Card.exist?(nname)
    nname = "#{nname} 1"
    nname.next! while Card.exist?(nname)
  end
  nname
end

format :html do
  before :box do
    voo.show! :customize_button, :box_middle
  end

  view :one_line_content do
    ""
  end

  view :customize_button, cache: :never do
    customize_button
  end

  def new_skin_path_args new_name
    { name: new_name,
      type: :bootstrap_skin,
      fields: { parent: card.name } }
  end

  def customize_button target: parent&.card, text: "Apply and customize"
    return "" if card.parent?
    # remove? perhaps we should be able to further customize a customized skin

    new_name = card.new_customized_name
    link_to_card target, text,
                 path: { action: :update,
                         card: {
                           content: new_name,
                           subcards: { new_name => new_skin_path_args(new_name) }
                         } },
                 class: "btn btn-sm btn-outline-primary me-2"
  end

  view :bar_left do
    class_up "card-title", "my-0 ms-2"
    class_up "media-left", "m-0"
    text_with_image size: :medium, title: "", text: _render_title,
                    media_opts: { class: "align-items-center" }
    # field_nest(:image, view: :core) + wrap_with(:h4, render(:title))
  end

  view :bar_right do
    customize_button
  end

  view :bar_bottom do
    wrap_with :code do
      render_core
    end
  end
end
