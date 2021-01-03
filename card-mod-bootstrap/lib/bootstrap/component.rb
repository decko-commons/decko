class Bootstrap
  # render components of bootstrap library
  class Component
    def initialize context, *args, &block
      @context = context
      @content = ["".html_safe]
      @args = args
      @child_args = []
      @append = []
      @wrap = []
      @build_block = block
      @html = Builder::XmlMarkup.new
    end

    class << self
      def render format, *args, &block
        new(format, *args, &block).render
      end

      # Like def_tag_method but always generates a div tag
      # The tag option is not available
      def def_div_method name, html_class, opts={}, &tag_block
        def_tag_method name, html_class, opts.merge(tag: :div), &tag_block
      end

      # Defines a method that generates a html tag
      # @param method_name [Symbol, String] the name of the method. If no :tag option in tag_opts is defined then the name is also the name of the tag that the method generates
      # @param html_class [String] a html class that is added to tag. Use nil if you don't want a html_class
      # @param tag_opts [Hash] additional argument that will be added to the tag
      # @option tag_opts [Symbol, String] tag the name of the tag
      # @example
      #   def_tag_method :link, "known-link", tag: :a, id: "uniq-link"
      #   link  # => <a class="known-link" id="uniq-link"></a>
      def def_tag_method method_name, html_class, tag_opts={}, &tag_opts_block
        tag = tag_opts.delete(:tag) || method_name
        return def_simple_tag_method method_name, tag, html_class, tag_opts unless block_given?

        define_method method_name do |*args, &content_block|
          content, opts, new_child_args = standardize_args args, &tag_opts_block
          add_classes opts, html_class, tag_opts.delete(:optional_classes)

          @html.tag! tag, opts do
            instance_exec &content_block
          end
        end
      end

      def def_simple_tag_method method_name, tag, html_class, tag_opts={}
        define_method method_name do |*args, &content_block|
          @html.tag! tag, class: html_class do
            instance_exec &content_block
          end
        end
      end
    end

    def render
      @rendered = begin
        render_content
        # @content[-1]
      end
    end

    def prepend &block
      tmp = @content.pop
      instance_exec &block
      @content << tmp
    end

    def insert &block
      instance_exec &block
    end

    def append &block
      @append[-1] << block
    end

    def wrap tag=nil, &block
      @wrap[-1] << (block_given? ? block : tag)
    end

    private

    def render_content
      # if @build_block.arity > 0
      instance_exec *@args, &@build_block
    end

    def generate_content content, processor, &block
      content = instance_exec &block if block.present?
      return content if !processor || !content.is_a?(Array)
      content.each {|item| send processor, item}
      ""
    end

    def with_child_args args
      @child_args << args if args.present?
      res = yield
      @child_args.pop if args.present?
      res
    end

    def add_content content
      @content[-1] << "\n#{content}".html_safe if content.present?
    end

    def standardize_args args, &block
      opts = standardize_opts args
      items = items_from_args args
      opts, args = standardize_block_args opts, args, &block if block.present?

      [items, opts, args]
    end

    def standardize_opts args
      args.last.is_a?(Hash) ? args.pop : {}
    end

    def items_from_args args
      ((args.one? && args.last.is_a?(String)) || args.last.is_a?(Array)) && args.pop
    end

    def standardize_block_args opts, args, &block
      instance_exec(opts, args, &block).tap do |s_opts, _s_args|
        unless s_opts.is_a? Hash
          raise Card::Error, "first return value of a tag block has to be a hash"
        end
      end
    end

    def add_classes opts, html_class, optional_classes
      prepend_class opts, html_class if html_class
      Array.wrap(optional_classes).each do |k, v|
        prepend_class opts, v if opts.delete k
      end
    end

    include BasicTags
    include Delegate
  end
end
