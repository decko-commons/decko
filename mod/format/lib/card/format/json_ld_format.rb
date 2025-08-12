class Card
  class Format
    # card format class for json (JavaScript Object Notation) views
    class JsonLdFormat < JsonFormat
      Mime::Type.register "application/ld+json", :json_ld
      register :json_ld


      def mime_type
        "application/ld+json"
      end
    end
  end
end
