class Card
  class Layout
    class << self
      BUILT_IN_LAYOUTS_KEY = "__BUILT_IN_LAYOUT"
      LAYOUTS_KEY = "__LAYOUT"

      def render layout, format
        layout_class =
          if layout.respond_to?(:call)
            Card::Layout::ProcLayout
          elsif card_layout?(layout)
            Card::Layout::CardLayout
          elsif code_layout?(layout)
            Card::Layout::CodeLayout
          else
            Card::Layout::UnknownLayout
          end
        layout_class.new(layout, format).render
      end

      def card_layout? name
        Card.fetch_type_id(name) == Card::LayoutTypeID
      rescue Card::Error::CodenameNotFound => _e
        false
      end

      def code_layout? name
        built_in_layouts_hash.key? name
      end

      # def cache
      #   Card::Cache[self]
      # end

      def register_layout new_layout, main_opts={}
        l = layouts
        return if l[new_layout]
        l[new_layout] = main_opts
        # cache.write(LAYOUTS_KEY, layouts)
      end

      def register_built_in_layout new_layout
        register_layout new_layout
        built_in_layouts_hash[new_layout] = true
        # cache.write(BUILT_IN_LAYOUTS_KEY, layouts)
      end

      def built_in_layouts_hash
        @built_in_layouts ||= {}
        # cache.fetch(BUILT_IN_LAYOUTS_KEY) { Hash.new }
      end

      def built_in_layouts
        built_in_layouts_hash.keys
      end

      def layouts
        @layouts ||= {}
        # cache.fetch(LAYOUTS_KEY) { Hash.new }
      end

      def main_nest_opts layout_name
        layouts[layout_name] || {}
      end
    end

    def initialize layout, format
      @layout = layout
      @format = format
    end

    def main_nest_opts
      self.class.main_nest_opts @layout
    end
  end
end
