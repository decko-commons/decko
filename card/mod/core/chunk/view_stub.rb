class Card
  class Content
    module Chunk
      class ViewStub < Abstract
        Chunk.register_class(
          self,
          prefix_re: Regexp.escape("(stub)"),
          full_re: /\(stub\)([^\(]*)\(\/stub\)/,
          idx_char: "("
        )

        def initialize text, content
          super
        end

        def interpret match, _content
          @options_json = match[1]
          @stub_hash = JSON.parse(Card::View::Stub.unescape @options_json).symbolize_keys
          interpret_hash_values
        end

        def interpret_hash_values
          @stub_hash.keys.each do |key|
            send "interpret_#{key}"
          end
        end

        def interpret_cast
          @stub_hash[:cast].symbolize_keys!
        end

        def interpret_options
          @stub_hash[:options].symbolize_keys!
        end

        def interpret_mode
          @stub_hash[:mode] = @stub_hash[:mode].to_sym
        end

        def interpret_override
          @stub_hash[:override] = @stub_hash[:override] == "true"
        end

        def process_chunk
          @processed = yield @stub_hash
        end

        def result
          @processed
        end
      end
    end
  end
end
