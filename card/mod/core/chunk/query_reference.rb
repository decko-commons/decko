# -*- encoding : utf-8 -*-

class Card
  class Content
    module Chunk
      # This should find +Alfred+ in expressions like
      # 1) {"name":"Alfred"}
      # 2a) {"name":["in","Alfred"]}
      # 3a) {"plus_right":["Alfred"]}
      # but not in
      # 2b) "content":"foo", "Alfred":"bar"
      # 3b) {"name":["Alfred", "Toni"]}      ("Alfred" is an operator here)
      # It's not possible to distinguish between 2a) and 2b) or 3a) and 3b) with a
      # simple regex, hence we use a too general regex and check for query keywords
      # after the match, which of course means that we don't find references with
      # query keywords as name

      require File.expand_path("reference", __dir__)
      class QueryReference < Reference
        QUERY_KEYWORDS = ::Set.new(
          (
            ::Card::Query::MODIFIERS.keys +
            ::Card::Query::OPERATORS.keys +
            ::Card::Query::ATTRIBUTES.keys +
            ::Card::Query::CONJUNCTIONS.keys +
            %w[desc asc count]
          ).map(&:to_s)
        )

        Card::Content::Chunk.register_class(
          self, prefix_re: '(?<=[:,\\[])\\s*"',
                # we check for colon, comma or square bracket before a quote
                # we have to use a lookbehind, otherwise
                # if the colon matches it would be
                # identified mistakenly as an URI chunk
                full_re: /\A\s*"([^"]+)"/,
                idx_char: '"'
        )

        # OPTIMIZE: instead of comma or square bracket check for operator followed
        # by comma or "plus_right"|"plus_left"|"plus" followed by square bracket
        # something like
        # prefix_patterns = [
        #  "\"\\s*(?:#{Card::Query::OPERATORS.keys.join('|')})\"\\s*,",
        #  "\"\\s*(?:#{Card::Query::PLUS_ATTRIBUTES}.keys
        #    .join('|')})\\s*:\\s*\\[\\s*",
        #  "\"\\s*(?:#{(QUERY_KEYWORDS - Card::Query::PLUS_ATTRIBUTES)
        #    .join('|')})\"\\s*:",
        # ]
        # prefix_re: '(?<=#{prefix_patterns.join('|')})\\s*"'
        # But: What do we do with the "in" operator? After the first value there is
        # no prefix which we can use to detect the following values as
        # QueryReference chunks

        class << self
          def full_match content, prefix
            # matches cardnames that are not keywords
            # FIXME: would not match cardnames that are keywords
            match, offset = super(content, prefix)
            return if !match || keyword?(match[1])

            [match, offset]
          end

          def keyword? str
            return unless str

            QUERY_KEYWORDS.include?(str.tr(" ", "_").downcase)
          end
        end

        def interpret match, _content
          @name = match[1]
        end

        def process_chunk
          @process_chunk ||= @text
        end

        def inspect
          "<##{self.class}:n[#{@name}] p[#{@process_chunk}] txt:#{@text}>"
        end

        def replace_reference old_name, new_name
          replace_name_reference old_name, new_name
          @text = "\"#{@name}\""
        end

        def reference_code
          "Q" # for "Query"
        end
      end
    end
  end
end
