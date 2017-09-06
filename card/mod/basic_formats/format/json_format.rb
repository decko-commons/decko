# -*- encoding : utf-8 -*-

class Card
  class Format
    class JsonFormat < DataFormat
      register :json

      def content_type
        "text/json"
      end
    end
  end
end
