include_set Abstract::Css

format :css do
  view :compiled do
    compile_scss _render_core
  end

  view :core do
    process_content(_render_raw)
  end

  def compile_scss scss, style=:expanded
    # return scss if Rails.env.development?
    SassC::Engine.new(scss, style: style).render
  rescue SassC::SyntaxError => e
    raise Card::Error,
          "SassC::SyntaxError (#{card.name}:#{e.sass_backtrace}): #{e.message}"
    # "#{#scss.lines[e.sass_line - 1]}\n" \
  end
end

format :scss do
  view :labeled do
    "//#{card.name}\n#{_render_core}"
  end

  view :core do
    process_content _render_raw
  end
end

format :html do
  def ace_mode
    :scss
  end
end
