format :html do
  def show view, args
    content = send show_method, view, args
    Env.ajax? || no_layout? ? content : wrap_with_html_page(content)
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

  private

  def head_content
    nest card.rule_card(:head), view: :head_content
  end

  def show_without_page_layout view, args
    @main = true if params[:is_main] || args[:main]
    args.delete(:layout)
    view ||= args[:home_view] || default_page_view
    render! view, args
  end

  def default_page_view
    default_nest_view
  end

  def show_method
    "show_#{show_layout? ? :with : :without}_page_layout"
  end

  def show_layout?
    return false if no_layout?

    !Env.ajax? || params[:layout]
  end

  def no_layout?
    params[:layout] == "none"
  end
end
