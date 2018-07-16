format :html do
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
      bridge_layout
    end
  end

  layout :modal do
    modal_layout
  end

  layout :overlay do
     class_up "card-slot", "_overlay d0-card-overlay bg-white", true
     @content_body = true
     overlay_main
  end

  def modal_layout
    <<-HTML
      <div class="modal-header clearfix">
        #{render_modal_menu}
      </div>
      <div class="modal-body ">
        #{layout_nest}
      </div>
      <div class="modal-footer">
        #{render_modal_footer}
      </div>
    HTML
  end
end