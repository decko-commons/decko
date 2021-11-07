# -*- encoding : utf-8 -*-

class Card
  class Format
    class YamlFormat < DataFormat
      register :yaml
      register :yml
      aliases["yml"] = "yaml"

      def mime_type
        "text/x-yaml"
      end
    end
  end
end
