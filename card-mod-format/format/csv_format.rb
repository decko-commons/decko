# -*- encoding : utf-8 -*-

class Card
  class Format
    class CsvFormat < TextFormat
      register :csv

      def mime_type
        "text/comma-separated-values"
      end

      def self.view_caching?
        # TODO: make view caching handle non-strings
        # (specifically stub_render)
        false
      end
    end
  end
end
