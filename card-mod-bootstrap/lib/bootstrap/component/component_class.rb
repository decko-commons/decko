class Bootstrap
  class Component
    # class methods for Bootstrap::Component
    module ComponentClass
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
            instance_exec(&content_block)
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
  end
end
