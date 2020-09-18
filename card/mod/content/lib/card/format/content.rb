class Card
  class Format
    module Content
      def process_content override_content=nil, content_opts=nil, &block
        content_obj = content_object override_content , content_opts
        content_obj.process_chunks(&block)
        content_obj.to_s
      end

      # Preserves the syntax in all nests. The content is yielded with placeholders
      # for all nests. After executing the given block the original nests are put back in.
      # Placeholders are numbers in double curly brackets like {{2}}.
      def safe_process_content override_content=nil, content_opts=nil, &block
        content_obj =
          content_object override_content, chunk_list: :references_keep_escaping
        result = content_obj.without_references(&block)
        process_content result, content_opts
      end

      # nested by another card's content
      # (as opposed to a direct API nest)
      def content_nest opts={}
        return opts[:comment] if opts.key? :comment # commented nest

        nest_name = opts[:nest_name]
        return main_nest(opts) if main_nest?(nest_name) && @nest_mode != :template

        nest nest_name, opts
      end

      def format_date date, include_time=true
        # using DateTime because Time doesn't support %e on some platforms
        if include_time
          # .strftime('%B %e, %Y %H:%M:%S')
          I18n.localize(DateTime.new(date.year, date.mon, date.day,
                                     date.hour, date.min, date.sec),
                        format: :card_date_seconds)
        else
          # .strftime('%B %e, %Y')
          I18n.localize(DateTime.new(date.year, date.mon, date.day),
                        format: :card_date_only)
        end
      end

      def add_class options, klass
        return if klass.blank?

        options[:class] = css_classes options[:class], klass
      end

      alias_method :append_class, :add_class

      def prepend_class options, klass
        options[:class] = css_classes klass, options[:class]
      end

      def css_classes *array
        array.flatten.uniq.compact * " "
      end

      def id_counter
        return @parent.id_counter if @parent

        @id_counter ||= 0
        @id_counter += 1
      end

      def unique_id
        "#{card.name.safe_key}-#{id_counter}"
      end

      def output *content
        content = yield if block_given?
        Array.wrap(content).flatten.compact.join "\n"
      end

      private

      def content_object content=nil, content_opts=voo&.content_opts
        return content if content.is_a? Card::Content

        content ||= render_raw || ""
        Card::Content.new content, self, content_opts
      end


    end
  end
end
