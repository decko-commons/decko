format :html do
  def show view, args
    content = send show_method, view, args
    show_full_page? ? wrap_with_html_page(content) : content

  # TODO: remove the following after tracking down wikirate encoding bug
  rescue Card::Error::ServerError => e
    if e.message.match?(/invalid byte sequence/)
      Card::Lexicon.cache.reset
      Rails.logger.info "reset name cache to prevent encoding freakiness"
    end
    raise e
  end

  def show_method
    "show_#{show_layout? ? :with : :without}_page_layout"
  end

  def show_without_page_layout view, args
    @main = true if params[:is_main] || args[:main]
    args.delete(:layout)
    view ||= args[:home_view] || :open # default_nest_view
    render! view, args
  end

  def show_full_page?
    !Env.ajax?
  end

  wrapper :html_page do
    <<-HTML.strip_heredoc
      <!DOCTYPE HTML>
      <html class="h-100">
        <head>
          #{head_content}
        </head>
        #{interior}
      </html>
    HTML
  end

  def head_content
    nest card.rule_card(:head), view: :head_content
  end
end
