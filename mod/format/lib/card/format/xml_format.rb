# -*- encoding : utf-8 -*-

class Card
  class Format
    # card format class for xml (extensible markup language) views
    class XmlFormat < DataFormat
      register :xml

      def mime_type
        "text/xml"
      end
    end
  end
end
