format :html do
  def wrap_with_layout layout, &block
    voo.wrap_with_layout layout, &block
  end

  def layout_nest
    voo.render_layouts
  end

  layout :pre do  #{{_main|raw}}
    wrap_with :pre do
      layout_nest
    end
  end

  layout :simple do
    layout_nest
  end

  layout :no_side do # {{_main|open}}
    <<-HTML.strip_heredoec
      <header>#{nest :header, view: :core}</header>
      <article>#{layout_nest}</article>
      <footer>{nest :footer, view: :core}</footer>
    HTML
  end

  layout :default do
    <<-HTML.strip_heredoc
      <header>#{nest :header, view: :core}</header>
      <article>#{layout_nest}</article>
      <aside>#{nest :sidebar, view: :core}</aside>
      <footer>{nest :footer, view: :core}</footer>
    HTML
  end

  # view :edit, layout:

  layout :bridge do
    wrap_with_layout :modal do
      haml BRIDGE_HAML
    end
  end

  layout :modal do
    haml MODAL_HAML
  end

  layout :overlay do
     class_up "card-slot", "_overlay d0-card-overlay bg-white", true
     @content_body = true
     overlay_main
  end

  MODAL_HAML =
    <<-HAML.strip_heredoc
      .modal-header.clearfix
        = render_modal_menu
      .modal-body
        = layout_nest
      .modal-footer
        = render_modal_footer
    HAML

  BRIDGE_HAML =
    <<-HAML.strip_heredoc
      .bridge
        .row{class: classy("card-header")}
          = render_bridge_breadcrumbs
        .row
          .col-8.bridge-main
            = layout_nest
          .col-4.bridge-sidebar
            = render_follow_buttons
            = render_bridge_tabs
    HAML
end
