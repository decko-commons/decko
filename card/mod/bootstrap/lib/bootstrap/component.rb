#! no set module
class Bootstrap
  class TagMethod
    def initialize component, name, html_class, tag_opts={}, &tag_block
      @component = component
      @name = name
      @html_class = html_class
      @tag_opts = tag_opts
      @tag_block = tag_block
      @append = []
      @wrap = []
      @xm = Builder::XmlMarkup.new
    end

    def call *args, &content_block
      component.content.push "".html_safe

      content, opts = content_block.call
      wrappers = @wrap.pop
      if wrappers.present?
        while wrappers.present? do
          wrapper = wrappers.shift
          if wrapper.is_a? Symbol
            send wrapper, &content_block
          else
            instance_exec(content, &wrappers.shift)
          end
        end
      else
        add_content content
      end

      collected_content = @content.pop
      tag_name = opts.delete(:tag) if tag_name == :yield
      add_content content_tag(tag_name, collected_content, opts, false)
      @append.pop.each do |block|
        add_content instance_exec(&block)
      end
      ""
    end

    def method_missing method, *args, &block
      @component.send method, *args, &block
    end

    def prepend &block
      tmp = @content.pop
      instance_exec &block
      @content << tmp
    end

    def wrap &block
      instance_exec &block
    end

    def append &block
      @append[-1] << block
    end

    def wrapInner tag=nil, &block
      @wrap[-1] << (block_given? ? block : tag)
    end
  end

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
      # @param name [Symbol, String] the name of the method. If no :tag option in tag_opts is defined then the name is also the name of the tag that the method generates
      # @param html_class [String] a html class that is added to tag. Use nil if you don't want a html_class
      # @param tag_opts [Hash] additional argument that will be added to the tag
      # @option tag_opts [Symbol, String] tag the name of the tag
      # @example
      #   def_tag_method :link, "known-link", tag: :a, id: "uniq-link"
      #   link  # => <a class="known-link" id="uniq-link"></a>
      # def add_tag_method name, html_class, tag_opts={}, &tag_block
      #   @tag_method = TagMethod.new self,name, html_class, tag_opts, &tag_block
      #   define_method name do |*args, &block|
      #     @tag_method.call *args, &block
      #     process_tag tag_opts[:tag] || name do
      #       content, opts, new_child_args = standardize_args args, &tag_block
      #       add_classes opts, html_class, tag_opts.delete(:optional_classes)
      #       if (attributes = tag_opts.delete(:attributes))
      #         opts.merge! attributes
      #       end
      #
      #       content = with_child_args new_child_args do
      #         generate_content content,
      #                          tag_opts[:content_processor],
      #                          &block
      #       end
      #
      #       [content, opts]
      #     end
      #   end
      # end

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

    def process_tag tag_name, &content_block
    end

    def standardize_args args, &block
      opts = args.last.is_a?(Hash) ? args.pop : {}
      items = ((args.one? && args.last.is_a?(String)) || args.last.is_a?(Array)) &&
        args.pop
      if block.present?
        opts, args = instance_exec opts, args, &block
        unless opts.is_a?(Hash)
          raise Card::Error, "first return value of a tag block has to be a hash"
        end
      end

      [items, opts, args]
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
