# -*- encoding : utf-8 -*-

class Card
  class Content
    module Chunk
      # These are basic chunks that have a pattern and can be protected.
      # They are used by rendering process to prevent wiki rendering
      # occuring within literal areas such as <code> and <pre> blocks
      # and within HTML tags.
      class EscapedLiteral < Abstract
        FULL_RE = { "[" => /\A\\\[\[[^\]]*\]\]/,
                    "{" => /\A\\\{\{[^\}]*\}\}/ }.freeze
        Card::Content::Chunk.register_class self,
                                            prefix_re: '\\\\(?:\\[\\[|\\{\\{)',
                                            idx_char:  '\\'

        def self.full_re prefix
          FULL_RE[prefix[1, 1]]
        end

        def interpret match, _content
          @process_chunk = match[0].sub(/^\\(.)/, format.escape_literal('\1'))
        end
      end
    end
  end
end
