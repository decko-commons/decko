# -*- encoding : utf-8 -*-

class Card
  class Format
    class EmailTextFormat < Card::Format::TextFormat
      def chunk_list
        :references
      end
    end
  end
end
