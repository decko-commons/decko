class Card
  class Format
    # card format class for json (JavaScript Object Notation) views
    class JsonldFormat < JsonFormat
      Mime::Type.register "application/ld+json", :jsonld
      register :jsonld

      def mime_type
        "application/ld+json"
      end

      # overrides #page_details in Json format, which adds standard info to every request
      def page_details obj
        obj
      end
    end
  end
end
