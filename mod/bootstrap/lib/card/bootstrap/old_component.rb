class Card
  class Bootstrap
    # not-yet-obviated component handling
    class OldComponent < Component
      include Content

      def initialize(context, *args, &)
        super
        @html = nil
      end

      class << self
        def render(format, ...)
          new(format, ...).render
        end

        # Like add_tag_method but always generates a div tag
        # The tag option is not available
        def add_div_method(name, html_class, opts={}, &)
          add_tag_method(name, html_class, opts.merge(tag: :div), &)
        end

        # Defines a method that generates a html tag
        # @param name [Symbol, String] the name of the method. If no :tag option in
        #   tag_opts is defined then the name is also the name of the tag that the method
        #   generates
        # @param html_class [String] a html class that is added to tag. Use nil if you
        #   don't want a html_class
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

      private

      def process_tag(tag_name, &)
        @content.push "".html_safe
        @append << []
        @wrap << []

        opts = process_content(&)
        process_collected_content tag_name, opts
        process_append
        ""
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
end
