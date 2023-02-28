# -*- encoding : utf-8 -*-

load File.expand_path("reference.rb", __dir__)

class Card
  class Content
    module Chunk
      class Link < Reference
        CODE = "L".freeze # L for "Link"
        attr_reader :link_text

        Chunk.register_class self, prefix_re: '\\[\\[',
                                   full_re: /\A\[\[([^\]]+)\]\]/,
                                   idx_char: "["

        def reference_code
          CODE
        end

        def process_chunk
          @process_chunk ||= render_link
        end

        def inspect
          "<##{self.class}:e[#{@explicit_link}]n[#{@name}]l[#{@link_text}]" \
          "p[#{@process_chunk}] txt:#{@text}>"
        end

        # view options
        def options
          link_text ? { title: link_text } : {}
        end

        def swap_name old_name, new_name
          replace_name_reference old_name, new_name
          replace_link_text old_name, new_name
          link_text_syntax = "|#{@link_text}" if @link_text.present?
          @text = "[[#{referee_name}#{link_text_syntax}]]"
        end

        def explicit_link?
          @explicit_link
        end

        def render_link view: :link, explicit_link_opts: {}
          @link_text = render_obj @link_text

          if @explicit_link
            render_explicit_link explicit_link_opts
          elsif @name
            render_name_link view
          end
        end

        def link_target
          if @explicit_link
            render_obj @explicit_link
          elsif @name
            referee_name
          end
        end

        private

        def render_explicit_link explicit_link_opts
          @explicit_link = render_obj @explicit_link
          format.link_to_resource @explicit_link, @link_text, explicit_link_opts
        end

        def render_name_link view
          format.with_nest_mode :normal do
            format.nest referee_name, options.merge(view: view)
          end
        end

        # interpret a chunk matching
        def interpret match, _content
          target, @link_text = target_and_link_text match[1]

          @link_text = objectify @link_text
          if target.match? %r{^(/|https?:|mailto:)}
            @explicit_link = objectify target
          else
            @name = target
          end
        end

        def target_and_link_text raw_syntax
          return unless raw_syntax

          if (i = divider_index raw_syntax)                    # if [[A | B]]
            [raw_syntax[0..(i - 1)], raw_syntax[(i + 1)..-1]]  # [A, B]
          else                                                 # else must be [[ A ]]
            [raw_syntax, nil]                                  # [A, nil]
          end
        end

        def divider_index string
          # there's probably a better way to do the following.
          # point is to find the first pipe that's not inside an nest
          return unless string.index "|"

          string_copy = string.dup
          string.scan(/\{\{[^}]*\}\}/) do |incl|
            string_copy.gsub! incl, ("x" * incl.length)
          end
          string_copy.index "|"
        end

        # turn a string into a Content object if it looks like it might have more
        # chunks in it
        def objectify raw
          return unless raw

          raw.strip!
          if raw.match?(/(^|[^\\])\{\{/)
            Content.new raw, format
          else
            raw
          end
        end

        def replace_link_text old_name, new_name
          replacing_content_object @link_text, old_name, new_name do
            @link_text = old_name.to_name.sub_in(@link_text, with: new_name)
          end
        end
      end
    end
  end
end
