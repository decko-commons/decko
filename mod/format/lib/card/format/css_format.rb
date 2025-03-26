# -*- encoding : utf-8 -*-

class Card
  class Format
    # card format class for css (cascading stylesheet) views
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
