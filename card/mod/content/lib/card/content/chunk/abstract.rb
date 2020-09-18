class Card
  class Content < SimpleDelegator
    # A chunk is a pattern of text that can be protected
    # and interrogated by a format. Each Chunk class has a
    # +pattern+ that states what sort of text it matches.
    # Chunks are initalized by passing in the result of a
    # match by its pattern.
    #
    module Chunk
      class Abstract
        class_attribute :config
        attr_reader :text, :process_chunk

        class << self
          # if the prefix regex matched check that chunk against the full regex
          def full_match content, prefix=nil
            content.match full_re(prefix)
          end

          def full_re _prefix
            config[:full_re]
          end

          def context_ok? _content, _chunk_start
            true
          end
        end

        def reference_code
          "I"
        end

        def initialize match, content
          match = self.class.full_match(match) if match.is_a? String
          @text = match[0]
          @processed = nil
          @content = content
          interpret match, content
        end

        def interpret _match_string, _content
          Rails.logger.info "no #interpret method found for chunk class: " \
                            "#{self.class}"
        end

        def format
          @content.format
        end

        def card
          @content.card
        end

        def to_s
          result
        end

        def result
          burn_read || @process_chunk || @processed || @text
        end

        def burn_read
          return unless @burn_read

          tmp = @burn_read
          @burn_read = nil
          tmp
        end

        # Temporarily overrides the processed nest content for single-use
        # After using the nest's result
        # (for example via `to_s`) the original result is restored
        def burn_after_reading text
          @burn_read = text
        end

        def inspect
          "<##{self.class}##{self}>"
        end

        def as_json _options={}
          burn_read || @process_chunk || @processed ||
            "not rendered #{self.class}, #{card&.name}"
        end
      end
    end
  end
end
