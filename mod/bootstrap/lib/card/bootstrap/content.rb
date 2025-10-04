class Card
  class Bootstrap
    # shared methods for OldComponent and TagMethod
    module Content
      private

      def process_collected_content tag_name, opts
        collected_content = @content.pop
        tag_name = opts.delete(:tag) if tag_name == :yield
        add_content content_tag(tag_name, collected_content, opts, false)
      end

      def process_content(&)
        content, opts = yield
        wrappers = @wrap.pop
        if wrappers.present?
          process_wrappers(wrappers, content, &)
        else
          add_content content
        end
        opts
      end

      def process_append
        @append.pop.each do |block|
          add_content instance_exec(&block)
        end
      end

      def process_wrappers(wrappers, content, &)
        while wrappers.present?
          wrapper = wrappers.shift
          if wrapper.is_a? Symbol
            send(wrapper, &)
          else
            instance_exec content, &wrappers.shift
          end
        end
      end
    end
  end
end
