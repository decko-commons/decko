format do
  include Card::Set::Format::HamlPaths

  define_method :the_scope do
    set_scope
  end

  define_method :haml_scope do
    set_scope
  end

  # Renders haml templates. The haml template can be passed as string or
  # block or a symbol that refers to a view template.
  # @param args [Hash, String, Symbol]
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
  #     haml :my_template, name: "Joe:  # => "<p>Hi Joe<p/>"
  #   end
  # @example use a block to pass haml
  #   haml name: "Joe" do
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

  def haml *args, &block
    if args.first.is_a? Symbol
      process_haml_template(*args)
    else
      process_haml(*args, &block)
    end
  end

  def haml_partial partial, locals={}
    locals[:template_path] ||= @template_path
    process_haml_template :"_#{partial}", locals
  end

  private

  def process_haml *args
    args.unshift yield if block_given?
    haml_to_html(*args)
  end

  def process_haml_template template_name, *args
    locals = args.first || {}
    path = identify_template_path template_name, locals
    with_template_path path do
      haml_to_html File.read(path), *args
    end
    # rescue => e
    #   raise Card::Error, "HAML error #{template_name}: #{e.message}\n#{e.backtrace}"
  end

  def identify_template_path view, locals={}
    base_path = locals.delete(:template_path) || caller_locations[2].path
    haml_template_path view, base_path
  end
end
