class Card
  class Content
    class Diff
      # Summary object for Diff processing
      class Summary
        def initialize opts
          opts ||= {}
          @remaining_chars = opts[:length] || 50
          @joint = opts[:joint] || "..."
          @chunks = []
        end

        def rendered
          @rendered ||= render
        end

        def add text
          add_chunk text, :added
        end

        def delete text
          add_chunk text, :deleted
        end

        def omit
          return unless @chunks.empty? || @chunks.last[:action] != :ellipsis

          add_chunk @joint, :ellipsis
        end

        def omits_content?
          @content_omitted || @remaining_chars.negative?
        end

        private

        def render
          truncate_overlap
          @chunks.map do |chunk|
            @content_omitted ||= chunk[:action] == :ellipsis
            render_chunk chunk[:action], chunk[:text]
          end.join
        end

        def add_chunk text, action
          return unless @remaining_chars.positive?

          add_chunk_to_list text, action
          @remaining_chars -= text.size
        end

        def add_chunk_to_list text, action
          @chunks << { action: action, text: text }
        end

        def render_chunk action, text
          case action
          when "+", :added
            Diff.render_added_chunk text
          when "-", :deleted
            Diff.render_deleted_chunk text
          else text
          end
        end

        def truncate_overlap
          return unless @remaining_chars.negative?

          process_ellipsis
          index = @chunks.size - 1
          process_remaining index
        end

        def process_remaining index
          process_overlap(index) ? break : (index -= 1) while process_remaining? index
        end

        def process_remaining? index
          @remaining_chars < @joint.size && index >= 0
        end

        def chunk_text index
          @chunks[index][:text]
        end

        def process_ellipsis
          return unless @chunks.last[:action] == :ellipsis

          @chunks.pop
          @content_omitted = true
          @remaining_chars += @joint.size
        end

        def process_overlap index
          return true if overlap_finished index

          @remaining_chars += chunk_text(index).size
          @chunks.delete_at(index)
          false
        end

        def overlap_finished index
          overlap_size = @remaining_chars + chunk_text(index).size
          if overlap_size == @joint.size
            replace_with_joint index
          elsif overlap_size > @joint.size
            cut_with_joint index
          else
            return false
          end
          true
        end

        def cut_with_joint index
          cut_range = 0..(@remaining_chars - @joint.size - 1)
          @chunks[index][:text] = chunk_text(index)[cut_range]
          @chunks[index][:text] += @joint
        end

        JOINT_REPLACEMENT = { added: :ellipis, deleted: :added }.freeze

        def replace_with_joint index
          @chunks.pop
          return unless index.positive? &&
                        (previous_action = JOINT_REPLACEMENT[@chunks[index - 1][:action]])

          add_chunk_to_list @joint, previous_action
        end
      end
    end
  end
end
