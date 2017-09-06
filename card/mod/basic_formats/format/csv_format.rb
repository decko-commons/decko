# -*- encoding : utf-8 -*-

class Card
  class Format
    class CsvFormat < TextFormat
      register :csv

      def content_type
        "text/comma-separated-values"
      end
    end
  end
end
