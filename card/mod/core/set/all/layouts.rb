format :html do
  attr_reader :interior

  def layout_nest
    wrap_main { interior }
  end

  layout :pre do  # {{_main|raw}}
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
end
