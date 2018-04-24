
format :css do
  def default_nest_view
    :raw
  end

  def show view, args
    view ||= :content
    render! view, args
  end

  view :titled do
    major_comment(%( Style Card: \\"#{card.name}\\" )) + _render_core
  end

  view :content do
    _render_core
  end

  view :missing do
    major_comment "MISSING Style Card: #{card.name}"
  end

  view :import do
    _render_core
  end

  view :url, perms: :none do
    path mark: card.name, format: :css
  end

  def major_comment comment, char="-"
    edge = %(/* #{char * (comment.length + 4)} */)
    main = %(/* #{char} #{comment} #{char} */)
    "#{edge}\n#{main}\n#{edge}\n\n"
  end
end
