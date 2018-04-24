class Card
  class Format
    module Content
      def process_content override_content=nil, content_opts=nil
        content = override_content || render_raw || ""
        content_object = get_content_object content, content_opts
        content_object.process_each_chunk do |chunk_opts|
          content_nest chunk_opts
        end
        content_object.to_s
      end

      # nested by another card's content
      # (as opposed to a direct API nest)
      def content_nest opts={}
        return opts[:comment] if opts.key? :comment # commented nest
        nest_name = opts[:nest_name]
        return main_nest(opts) if main_nest?(nest_name)
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

      def get_content_object content, content_opts
        if content.is_a? Card::Content
          content
        else
          Card::Content.new content, self, (content_opts || voo&.content_opts)
        end
      end
    end
  end
end
