# -*- encoding : utf-8 -*-

class Card
  class Format
    class JsonFormat < DataFormat
      register :json

      def mime_type
        "text/json"
      end

      def expand_stubs cached_content, &block
        case cached_content
        when Hash
          cached_content.each do |k, v|
            cached_content[k] = expand_stubs v, &block
          end
        when String
          super
        when Array
          cached_content.map { |item| expand_stubs item, &block }
        else
          cached_content
        end
      end
    end
  end
end
