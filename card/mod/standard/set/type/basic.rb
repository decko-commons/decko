format :html do
  view :open_content do
    with_table_of_contents _render_core
  end

  view :titled_content do
    with_table_of_contents _render_core
  end

  def with_table_of_contents content
    table_of_contents(content) || content
  end

  def table_of_contents content
    return if nest_mode == :compact || !content.present?

    min = card.rule(:table_of_contents).to_i
    return unless min && min > 0

    toc = toc_items content
    if toc.flatten.length >= min
      content.replace(
        %( <div class="table-of-contents"> <h5>#{tr(:toc)}</h5> ) +
          make_table_of_contents_list(toc) + "</div>" + content
      )
    end
  end

  def toc_items content
    toc = []
    dep = 1
    content.gsub!(/<(h\d)>(.*?)<\/h\d>/i) do |match|
      if $LAST_MATCH_INFO
        tag, value = $LAST_MATCH_INFO[1, 2]
        value = strip_tags(value).strip
        next if value.empty?
        item = { value: value, uri: CGI.escape(value) }
        case tag.downcase
        when "h1"
          item[:depth] = dep = 1
          toc << item
        when "h2"
          toc << [] if dep == 1
          item[:depth] = dep = 2
          toc.last << item
        end
        %(<a name="#{item[:uri]}"></a>#{match})
      end
    end
    toc
  end

  def make_table_of_contents_list items
    list = items.map do |i|
      if i.is_a?(Array)
        make_table_of_contents_list(i)
      else
        %(<li><a href="##{i[:uri]}"> #{i[:value]}</a></li>)
      end
    end.join("\n")
    "<ol>" + list + "</ol>"
  end
end
