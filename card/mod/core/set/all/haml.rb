
#set_scope = "haml"

format do
  define_method :the_scope do
    set_scope
  end

  define_method :haml_scope do
    set_scope
  end
end

format do
  # Renders haml templates. The haml template can be passed as string or
  # block or a symbol that refers to a view template.
  # @param  template_or_locals [Hash, String, Symbol]
  #   If a symbol is given then a template is expected in the corresponding view
  #   directory.
  # @return [String] rendered haml as HTML
  # @example render a view template
  #   # view/type/basic/my_template.haml:
  #   %p
  #     Hi
  #     = name
  #
  #   # set/type/basic.rb:
  #   view :my_view do
  #     render_haml :my_template, name: "Joe:  # => "<p>Hi Joe<p/>"
  #   end
  # @example use a block to pass haml
  #   render_haml name: "Joe" do
  #     <<-HAML.strip_heredoc
  #       %p
  #         Hi
  #         = name
  #     HAML
  #   # => <p>Hi Joe</p>
  # @example create a slot in haml code
  #   - haml_wrap do
  #     %p
  #       some haml
  def render_haml template_or_locals={}, locals_or_binding=nil, a_binding=nil
    if template_or_locals.is_a? Symbol
      render_haml_template template_or_locals, locals_or_binding || {}
    elsif block_given?
      haml_to_html yield, template_or_locals, locals_or_binding
    else
      haml_to_html template_or_locals, locals_or_binding, a_binding
    end
  end

  def render_haml_partial partial, locals={}, a_binding=nil
    render_haml "_#{partial}".to_sym, locals, a_binding
  end

  def render_haml_template view, locals={}
    path = view_template_path view
    template = ::File.read path
    voo = View.new self, view, locals, @voo
    with_voo voo do
      haml_to_html template, locals
    end
  rescue => e
    raise Card::Error, "HAML error:\n  #{view}, #{path}\n:  #{e.message}"
  end

  include Card::Set::Format::HamlViews

  def haml_caller_path
    caller.each do |line|
      m = line.match /^(?<path>[^\:]*).*\`(?<method>.*)'$/
      next if m[:method] =~ /^(view_template|render_haml|with_voo)/
      next if m[:path] =~ /haml/
      next unless m[:path] =~ /\.rb$/
      return m[:path]
    end
    raise "haml_caller_path_not_found"
  end

  def view_template_path view
    #, tmp_set_path=__FILE__
    #set_path = tmp_set_path.gsub %r{/tmp/set/mod\d+-([^/]+)/},
    #                             '/mod/\1/template/'
    haml_template_path view, haml_caller_path
  end
end
