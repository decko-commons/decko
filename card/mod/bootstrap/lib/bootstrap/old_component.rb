#! no set module
class Bootstrap
  class OldComponent < Component
    def initialize context, *args, &block
      @context = context
      @content = ["".html_safe]
      @args = args
      @child_args = []
      @append = []
      @wrap = []
      @build_block = block
    end

    class << self
      def render format, *args, &block
        new(format, *args, &block).render
      end

      # Like add_tag_method but always generates a div tag
      # The tag option is not available
      def add_div_method name, html_class, opts={}, &tag_block
        add_tag_method name, html_class, opts.merge(tag: :div), &tag_block
      end

      # Defines a method that generates a html tag
      # @param name [Symbol, String] the name of the method. If no :tag option in tag_opts is defined then the name is also the name of the tag that the method generates
      # @param html_class [String] a html class that is added to tag. Use nil if you don't want a html_class
      # @param tag_opts [Hash] additional argument that will be added to the tag
      # @option tag_opts [Symbol, String] tag the name of the tag
      # @example
      #   add_tag_method :link, "known-link", tag: :a, id: "uniq-link"
      #   link  # => <a class="known-link" id="uniq-link"></a>
      def add_tag_method name, html_class, tag_opts={}, &tag_block
        define_method name do |*args, &block|
          process_tag tag_opts[:tag] || name do
            content, opts, new_child_args = standardize_args args, &tag_block
            add_classes opts, html_class, tag_opts.delete(:optional_classes)
            if (attributes = tag_opts.delete(:attributes))
              opts.merge! attributes
            end

            content = with_child_args new_child_args do
              generate_content content,
                               tag_opts[:content_processor],
                               &block
            end

            [content, opts]
          end
        end
      end

      alias_method :def_div_method, :add_div_method
      alias_method :def_tag_method, :add_tag_method
    end

    def render
      @rendered = begin
        render_content
        @content[-1]
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
      @content.push "".html_safe
      @append << []
      @wrap << []


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

    # include BasicTags
    def html content
      add_content String(content).html_safe
      ""
    end

    add_div_method :div, nil do |opts, extra_args|
      prepend_class opts, extra_args.first if extra_args.present?
      opts
    end

    add_div_method :span, nil do |opts, extra_args|
      prepend_class opts, extra_args.first if extra_args.present?
      opts
    end

    add_tag_method :tag, nil, tag: :yield do |opts, extra_args|
      prepend_class opts, extra_args[1] if extra_args[1].present?
      opts[:tag] = extra_args[0]
      opts
    end

    include Delegate
  end
end
