# -*- encoding : utf-8 -*-

class Card
  class Format
    class TextFormat < Format
      register :text
      register :txt
      aliases["txt"] = "text"

      def self.view_caching?
        # probably overkill.  problem was with email text message
        false
      end
    end
  end
end
