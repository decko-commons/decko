# -*- encoding : utf-8 -*-

class Card
  class Format
    # Format text for use in plain text email messages
    class EmailTextFormat < Card::Format::TextFormat
      def chunk_list
        :references
      end
    end
  end
end
