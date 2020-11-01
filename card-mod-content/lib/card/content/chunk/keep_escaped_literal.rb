# -*- encoding : utf-8 -*-

class Card
  class Content
    module Chunk
      # These are basic chunks that have a pattern and can be protected.
      # This chunk is used for markdown processing to ensure that
      # the escaping survives the markdown rendering.
      class KeepEscapedLiteral < Abstract
        FULL_RE = { "[" => /\A\\\[\[[^\]]*\]\]/,
                    "{" => /\A\\\{\{[^\}]*\}\}/ }.freeze
        Card::Content::Chunk.register_class self,
                                            prefix_re: '\\\\(?:\\[\\[|\\{\\{)',
                                            idx_char:  '\\'

        def self.full_re prefix
          FULL_RE[prefix[1, 1]]
        end

        def interpret match, _content
          @process_chunk = match[0].sub(/^\\(.)/, '\\\\\\\\\1')
        end
      end
    end
  end
end
