class Card
  class Layout
    class CardLayout < Layout
      def layout_card
        @layout_card ||= Card.quick_fetch @layout
      end

      def render
        @format.process_content layout_card.content, chunk_list: :references
      end

      def fetch_main_nest_opts
        main_nest_opts_from_content
      end

      def main_nest_opts_from_content
        content = Card::Content.new(layout_card.content, @format, chunk_list: :nest_only)
        content.each_chunk do |chunk|
          return chunk.options if chunk.main?
        end
      end
    end
  end
end
