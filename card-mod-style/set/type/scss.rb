include_set Type::Css

format do
  view :core, cache: :never do
    compile_scss process_content(_render_raw)
  end

  def compile_scss scss, style=:expanded
    SassC::Engine.new(scss, style: style).render
  rescue SassC::SyntaxError => e
    raise Card::Error,
          "SassC::SyntaxError (#{card.name}:#{e.sass_backtrace}): #{e.message}"
    # "#{#scss.lines[e.sass_line - 1]}\n" \
  end
end

format :html do
  def ace_mode
    :scss
  end
end
