format :html do
  # Options
  # @param opts [Hash]
  # @option opts [String, Hash<name, href>] brand
  # @option opts [String] class
  # @option opts [Boolean] no_collapse
  # @option opts [:left, :right] toggle_align
  def navbar id, opts={}, &block
    nav_opts = opts[:navbar_opts] || {}
    nav_opts[:class] ||= opts[:class]
    add_class nav_opts,
              "navbar navbar-dark bg-#{opts.delete(:navbar_type) || 'primary'}"
    navbar_content id, opts, nav_opts, &block
  end

  private

  def navbar_content id, opts, nav_opts
    content = yield
    if opts[:no_collapse]
      navbar_nocollapse content, nav_opts
    else
      navbar_responsive id, content, opts, nav_opts
    end
  end

  def navbar_nocollapse content, nav_opts
    # content = wrap_with(:div, content)
    wrap_with :nav, nav_opts do
      wrap_with :div, content, class: "container-fluid"
    end
  end

  def navbar_responsive id, content, opts, nav_opts
    opts[:toggle_align] ||= :right
    wrap_with :nav, nav_opts do
      wrap_with :div, class: "container-fluid" do
        haml :navbar_responsive, id: id, content: content, opts: opts
      end
    end
  end

  # Generates HTML markup for a breadcrumb trail.
  # @param items [list]: A list of items representing the breadcrumb trail.
  # @return [String] HTML markup for the breadcrumb trail.
  def breadcrumb items
    wrap_with :ol, class: "breadcrumb" do
      items.map do |item|
        wrap_with :li, item, class: "breadcrumb-item"
      end.join
    end
  end
end
