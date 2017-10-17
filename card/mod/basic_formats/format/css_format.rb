# -*- encoding : utf-8 -*-

class Card
  class Format
    class CssFormat < Format
      register :css

      def mime_type
        "text/css"
      end

      def self.view_caching?
        false
      end
    end
  end
end
