format :html do
  def show view, args
    content = send "show_#{show_layout? ? :with : :without}_page_layout", view, args
    show_full_page? ? page_wrapper(content) : content
  end

  def show_without_page_layout view, args
    @main = true if params[:is_main] || args[:main]
    view ||= args[:home_view] || :open
    render! view, args
  end

  def show_with_page_layout view, args
    args[:view] = view if view
    args[:main] = true
    args[:main_view] = true
    assign_modal_opts view, args unless Env.ajax?
    view_opts = @modal_opts.present? ? {} : args
    layout = params[:layout] || card.rule_card(:layout)&.item_names&.first || :default
    render_with_layout view, layout, view_opts
    # FIXME: using title because it's a standard view option.  hack!
  end

  def show_full_page?
    !Env.ajax?
  end

  def page_wrapper content
    <<-HTML.strip_heredoc
      <!DOCTYPE HTML>
      <html>
        <head>
          #{head_content}
        </head>
        <body>
          #{content}
        </body>
      </html>
    HTML
  end

  def render_with_layout view, layout, args={}
    @main = false
    args[:layout] = [layout, args[:layout]].flatten.compact
    view_opts = Layout.new(args[:layout], self).main_nest_opts
    view ||= view_opts.delete(:view) || default_nest_view
    render! view, view_opts.merge(args)
  end

  def head_content
    nest card.rule_card(:head), view: :item_cores
  end
end
