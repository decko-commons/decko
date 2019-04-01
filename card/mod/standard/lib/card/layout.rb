class Card
  class Layout
    class << self
      def render layout, format
        layout_class(layout).new(layout, format).render
      end

      def layout_class layout
        if layout.respond_to?(:call)
          Card::Layout::ProcLayout
        elsif card_layout?(layout)
          Card::Layout::CardLayout
        elsif code_layout?(layout)
          Card::Layout::CodeLayout
        else
          Card::Layout::UnknownLayout
        end
      end

      def card_layout? name
        Card.fetch_type_id(name).in? [Card::LayoutTypeID, Card::HtmlID, Card::BasicID]
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

      def layout_key name
        return name if name.is_a? Symbol
        name.to_name.key.to_sym
      end

      def register_built_in_layout new_layout, opts
        register_layout(new_layout) { opts.present? ? opts : nil }
        built_in_layouts_hash[new_layout] = true
      end

      def built_in_layouts_hash
        @built_in_layouts ||= {}
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
        opts = layouts[key] || main_new_opts_from_nest(layout_name, format)
        opts.clone
      end

      def main_new_opts_from_nest layout_name, format
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
