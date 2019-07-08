class Card
  class Content
    module Chunk
      class ViewStub < Abstract
        Chunk.register_class(
          self,
          prefix_re: Regexp.escape("(stub)"),
          full_re: /\A\(stub\)([^\(]*)\(\/stub\)/,
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

        def interpret_view_opts
          @stub_hash[:view_opts].symbolize_keys!
        end

        def interpret_format_opts
          hash = @stub_hash[:format_opts]
          hash.symbolize_keys!
          hash[:nest_mode] = hash[:nest_mode].to_sym
          hash[:override] = hash[:override] == "true"
          hash[:context_names].map!(&:to_name)
        end

        def process_chunk
          @processed = format.stub_nest @stub_hash
        end

        def result
          @processed
        end
      end
    end
  end
end
