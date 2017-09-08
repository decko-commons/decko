# -*- encoding : utf-8 -*-

class Card
  class Format
    class CssFormat < Format
      register :css

      def content_type
        "text/css"
      end
    end
  end
end
