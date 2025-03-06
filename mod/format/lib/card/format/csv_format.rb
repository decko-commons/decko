# -*- encoding : utf-8 -*-

class Card
  class Format
    # card format class for csv (comma separated values) views
    class CsvFormat < Format
      register :csv

      def mime_type
        if params[:disposition] == "inline"
          "text/plain"
        else
          "text/comma-separated-values"
        end
      end

      def self.view_caching?
        # TODO: make view caching handle non-strings
        # (specifically stub_render)
        false
      end
    end
  end
end
