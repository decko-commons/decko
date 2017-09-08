# -*- encoding : utf-8 -*-

class Card
  class Format
    class XmlFormat < DataFormat
      register :xml

      def content_type
        "text/xml"
      end
    end
  end
end
