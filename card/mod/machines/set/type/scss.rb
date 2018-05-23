include_set Type::Css

format do
  view :core, cache: :never do
    compile_scss(process_content(_render_raw))
  end

  def compile_scss scss, style=:expanded
    Sass.compile scss, style: style
  rescue Sass::SyntaxError => e
    raise Card::Error, "Sass::SyntaxError (#{card.name}:#{e.sass_line}):" \
                       "#{scss.lines[e.sass_line - 1]}\n" \
                       "#{e.message}"
  end
end

format :html do
  def ace_mode
    :scss
  end
end
