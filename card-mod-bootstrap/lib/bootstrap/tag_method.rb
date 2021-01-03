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
end
