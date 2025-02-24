class Card
  class Layout
    class << self
      def render layout, format
        layout_class(layout).new(layout, format).render
      end

      def layout_class layout
        if layout.respond_to? :call
          ProcLayout
        elsif card_layout? layout
          CardLayout
        elsif code_layout? layout
          CodeLayout
        else
          UnknownLayout
        end
      end

      def card_layout? name
        Card.fetch_type_id(name).in? [LayoutTypeID, HtmlID, BasicID]
      rescue ArgumentError, Card::Error::CodenameNotFound => _e
        false
      end

      def code_layout? name
        built_in_layouts_hash.key? name.to_sym
      end

      def register_layout new_layout
        key = layout_key new_layout
        return if layouts[key]

        layouts[key] = block_given? ? yield : {}
      end

      def deregister_layout layout_name
        layouts.delete layout_key(layout_name)
      end

      def layout_key name
        return name if name.is_a? Symbol

        name.to_name.key.to_sym
      end

      def register_built_in_layout new_layout, opts
        register_layout(new_layout) { opts.present? ? opts : nil }
        built_in_layouts_hash[new_layout] = true
      end

      def built_in_layouts_hash
        @built_in_layouts_hash ||= {}
      end

      def built_in_layouts
        built_in_layouts_hash.keys
      end

      def layouts
        @layouts ||= {}
      end

      def clear_cache
        @built_in_layouts = @layouts = nil
      end

      def main_nest_opts layout_name, format
        key = layout_key layout_name
        opts = layouts[key] || register_layout_with_nest(layout_name, format)
        opts.clone
      end

      def register_layout_with_nest layout_name, format
        register_layout(layout_name) do
          layout_class(layout_name).new(layout_name, format).fetch_main_nest_opts
        end
      end
    end

    def initialize layout, format
      @layout = layout
      @format = format
    end

    def fetch_main_nest_opts
      {}
    end

    def main_nest_opts
      self.class.main_nest_opts @layout, @format
    end
  end
end
