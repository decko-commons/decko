# -*- encoding : utf-8 -*-

class Card
  class Format
    # base class for rendering in YAML (Yet Another Markup Language)
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
