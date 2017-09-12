# -*- encoding : utf-8 -*-

class Card
  class Format
    class CssFormat < Format
      register :css

      def content_type
        "text/css"
      end

      def view_caching?
        false
      end

    end
  end
end
