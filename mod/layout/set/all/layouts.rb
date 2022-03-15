format :html do
  delegate :interior, to: :voo

  def layout_nest
    wrap_main { interior }
  end

  layout :simple do
    body_tag { layout_nest }
  end

  layout :pre do  # {{_main|raw}}
    body_tag do
      wrap_with :pre do
        layout_nest
      end
    end
  end

  layout :no_side do # {{_main|open}}
    body_tag do
      <<-HTML.strip_heredoc
        <header>#{nest :header, view: :core}</header>
        <article>#{layout_nest}</article>
        <footer>{nest :footer, view: :core}</footer>
      HTML
    end
  end

  layout :default do
    body_tag do
      <<-HTML.strip_heredoc
        <header>#{nest :header, view: :core}</header>
        <article>#{layout_nest}</article>
        <aside>#{nest :sidebar, view: :core}</aside>
        <footer>{nest :footer, view: :core}</footer>
      HTML
    end
  end

  def body_tag klasses=""
    <<-HTML.strip_heredoc
      <body class="#{klasses}">
        #{yield}
      </body>
    HTML
  end
end
