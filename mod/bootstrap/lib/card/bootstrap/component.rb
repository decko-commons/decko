class Card
  class Bootstrap
    # render components of bootstrap library
    class Component
      extend ComponentKlass

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

      def render
        @rendered = render_content
      end

      def prepend(&)
        tmp = @content.pop
        instance_exec(&)
        @content << tmp
      end

      def insert(&)
        instance_exec(&)
      end

      def append &block
        @append[-1] << block
      end

      def wrap tag=nil, &block
        @wrap[-1] << (block_given? ? block : tag)
      end

      def card
        @context.context.card
      end

      private

      def tag_method_opts(args, html_class, tag_opts, &)
        opts = {}
        _blah, opts, _blah = standardize_args(args, &) if block_given?
        add_classes opts, html_class, tag_opts.delete(:optional_classes)
        opts
      end

      def render_content
        # if @build_block.arity > 0
        instance_exec(*@args, &@build_block)
      end

      def generate_content content, processor, &block
        content = instance_exec(&block) if block.present?
        return content if !processor || !content.is_a?(Array)

        content.each { |item| send processor, item }
        ""
      end

      def with_child_args args
        @child_args << args if args.present?
        yield.tap { @child_args.pop if args.present? }
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
end
