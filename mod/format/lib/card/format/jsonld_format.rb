class Card
  class Format
    # card format class for json (JavaScript Object Notation) views
    class JsonldFormat < JsonFormat
      Mime::Type.register "application/ld+json", :jsonld
      register :jsonld


      def mime_type
        "application/ld+json"
      end
    end
  end
end
