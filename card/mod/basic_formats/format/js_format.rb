# -*- encoding : utf-8 -*-

class Card
  class Format
    class JsFormat < Format
      register :js

      def self.view_caching?
        false
      end

      def mime_type
        "text/javascript"
      end
    end
  end
end
