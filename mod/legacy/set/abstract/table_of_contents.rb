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
    return if nest_mode == :compact || !content.present? || toc_minimum&.zero?

    toc = toc_items content
    return unless toc.flatten.length >= toc_minimum

    content.replace(%(
      <div class="table-of-contents">
        <h5>#{t :legacy_toc}</h5>
        #{make_table_of_contents_list toc}
      </div>#{content}
    ))
  end

  def toc_minimum
    @toc_minimum ||= card.rule(:table_of_contents).to_i
  end

  def toc_items content
    toc = []
    dep = 1
    content.gsub!(%r{<(h\d)>(.*?)</h\d>}i) do |match|
      if $LAST_MATCH_INFO
        tag, value = $LAST_MATCH_INFO[1, 2]
        value = strip_tags(value).strip
        next if value.empty?

        item = { value: value, uri: ERB::Util.url_encode(value) }
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
    "<ol>#{list}</ol>"
  end
end
