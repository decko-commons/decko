format :html do
  def wrap_with_layout layout, &block
    voo.wrap_with_layout layout, &block
  end

  def layout_nest
    @rendered_main_nest
  end

  def interiour
Z    @interiour
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
    <<-HTML.strip_heredoc
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

  wrapper :bridge do |interiour|
    @interiour = interiour
    wrap_with_modal do
      haml BRIDGE_HAML
    end
  end



  wrapper :overlay do
     class_up "card-slot", "_overlay d0-card-overlay bg-white", true
     @content_body = true
     overlay_frame true do
       layout_nest
     end
  end



  BRIDGE_HAML =
    <<-HAML.strip_heredoc
      .bridge
        .row{class: classy("card-header")}
          = render_bridge_breadcrumbs
        .row
          .col-8.bridge-main
            = interiour
          .col-4.bridge-sidebar
            = render_follow_buttons
            = render_bridge_tabs
    HAML
end
