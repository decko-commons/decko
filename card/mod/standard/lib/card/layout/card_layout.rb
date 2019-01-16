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
        find_main_nest_chunk&.options ||
          raise(Card::Error, "no main nest found in layout \"#{@layout}\"")
      end

      MAIN_NESTING_LIMIT = 5

      def find_main_nest_chunk card=layout_card, depth=0
        content = Card::Content.new(card.content, @format, chunk_list: :nest_only)
        return false unless content.each_chunk.count > 0

        main_chunk(content) || go_deeper(content, depth)
      end

      def go_deeper content, depth
        return false if depth > MAIN_NESTING_LIMIT

        content.each_chunk do |chunk|
          main_chunk = find_main_nest_chunk chunk.referee_card, depth + 1
          return main_chunk if main_chunk
        end
        false
      end

      def main_chunk content
        content.each_chunk.find(&:main?)
      end
    end
  end
end
