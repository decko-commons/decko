# -*- encoding : utf-8 -*-

# require File.expand_path("../reference", __FILE__)
load File.expand_path("../reference.rb", __FILE__)

class Card
  class Content
    module Chunk
      # extend ActiveSupport::Autoload
      # autoload :Reference , "reference"

      class Link < Card::Content::Chunk::Reference
        CODE = "L".freeze # L for "Link"
        attr_reader :link_text
        # Groups: $1, [$2]: [[$1]] or [[$1|$2]] or $3, $4: [$3][$4]
        Card::Content::Chunk.register_class self,
                                            prefix_re: '\\[\\[',
                                            full_re:   /\A\[\[([^\]]+)\]\]/,
                                            idx_char:  "["
        def reference_code
          CODE
        end

        def interpret match, _content
          target, @link_text =
            if (raw_syntax = match[1])
              if (i = divider_index(raw_syntax))  # [[A | B]]
                [raw_syntax[0..(i - 1)], raw_syntax[(i + 1)..-1]]
              else                                # [[ A ]]
                [raw_syntax, nil]
              end
            end

          @link_text = objectify @link_text
          if target.match? %r{^(/|https?:|mailto:)}
            @explicit_link = objectify target
          else
            @name = target
          end
        end

        def divider_index string
          # there's probably a better way to do the following.
          # point is to find the first pipe that's not inside an nest
          return unless string.index "|"
          string_copy = string.dup
          string.scan(/\{\{[^\}]*\}\}/) do |incl|
            string_copy.gsub! incl, ("x" * incl.length)
          end
          string_copy.index "|"
        end

        # view options
        def options
          link_text ? { title: link_text } : {}
        end

        def objectify raw
          return unless raw
          raw.strip!
          if raw =~ /(^|[^\\])\{\{/
            Card::Content.new raw, format
          else
            raw
          end
        end

        def render_link view: :link, explicit_link_opts: {}
          @link_text = render_obj @link_text

          if @explicit_link
            @explicit_link = render_obj @explicit_link
            format.link_to_resource @explicit_link, @link_text, explicit_link_opts
          elsif @name
            format.with_nest_mode :normal do
              format.nest referee_name, options.merge(view: view)
            end
          end
        end

        def link_target
          if @explicit_link
            render_obj @explicit_link
          elsif @name
            referee_name
          end
        end

        def process_chunk
          @process_chunk ||= render_link
        end

        def inspect
          "<##{self.class}:e[#{@explicit_link}]n[#{@name}]l[#{@link_text}]" \
      "p[#{@process_chunk}] txt:#{@text}>"
        end

        def replace_reference old_name, new_name
          replace_name_reference old_name, new_name
          replace_link_text old_name, new_name
          @text =
            @link_text.nil? ? "[[#{referee_name}]]" : "[[#{referee_name}|#{@link_text}]]"
        end

        def replace_link_text old_name, new_name
          if @link_text.is_a?(Card::Content)
            @link_text.find_chunks(Card::Content::Chunk::Reference).each do |chunk|
              chunk.replace_reference old_name, new_name
            end
          elsif @link_text.present?
            @link_text = old_name.to_name.sub_in(@link_text, with: new_name)
          end
        end

        def explicit_link?
          @explicit_link
        end
      end
    end
  end
end
