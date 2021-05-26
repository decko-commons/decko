class Card
  class Bootstrap
    # support html tag generation
    class TagMethod
      include Content

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

      def call *_args, &content_block
        component.content.push "".html_safe

        opts = process_content(&content_block)
        process_collected_content tag_name, opts
        process_append
        ""
      end

      def method_missing method, *args, &block
        return super unless respond_to_missing? method

        @component.send method, *args, &block
      end

      def respond_to_missing? method, _include_private=false
        @component.respond_to? method
      end

      def prepend &block
        tmp = @content.pop
        instance_exec(&block)
        @content << tmp
      end

      def wrap &block
        instance_exec(&block)
      end

      def append &block
        @append[-1] << block
      end

      def wrapInner tag=nil, &block
        @wrap[-1] << (block_given? ? block : tag)
      end
    end
  end
end
