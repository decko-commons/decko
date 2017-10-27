# -*- encoding : utf-8 -*-

class Card
  class Format
    class JsonFormat < DataFormat
      register :json

      def mime_type
        "text/json"
      end

      def expand_stubs content, &block
        case content
        when Hash
          content.each { |k, v| content[k] = expand_stubs v, &block }
        when Array
          content.map { |item| expand_stubs item, &block }
        else
          super
        end
      end
    end
  end
end
