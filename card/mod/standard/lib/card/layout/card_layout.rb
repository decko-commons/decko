class Card
  class Layout
    class CardLayout < Layout
      def initialize layout, format
        super
        Card::Layout.register_layout layout, main_nest_opts
      end

      def layout_card
        @layout_card ||= Card.quick_fetch @layout
      end

      def render
        @format.process_content layout_card.content, chunk_list: :references
        #do

        #end
      end

      def main_nest_opts_from_content
        Card::Content.new(layout_card.content, @format, chunk_list: :nest)
          .each_chunk do |chunk|
          if chunk.main?
            self.class.register_layout @layout, chunk.options
            return chunk.options
          end
        end
      end

      def main_nest_opts
        super || main_nest_opts_from_content
      end
    end
  end
end
