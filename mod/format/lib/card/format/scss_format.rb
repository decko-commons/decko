# -*- encoding : utf-8 -*-

class Card
  class Format
    # Scss format
    class ScssFormat < CssFormat
      register :scss

      def mime_type
        "text/x-scss"
      end

      def self.view_caching?
        false
      end
    end
  end
end
