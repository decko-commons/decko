class Card
  class Content
    # content-related methods for cards
    module All
      def content
        structured_content || standard_content
      end
      # alias_method :raw_content, :content # DEPRECATED!

      def content= value
        self.db_content = standardize_content value
      end

      def content?
        content.present?
      end

      def standard_content
        db_content || (new_card? ? default_content : "")
      end

      def standardize_content value
        value.is_a?(Array) ? items_content(value) : value
      end

      def structured_content
        structure && default_content
      end

      def refresh_content
        self.content = Card.find(id)&.db_content
      end

      def save_content_draft _content
        clear_drafts
      end

      def clear_drafts
        drafts.created_by(Card::Auth.current_id).each(&:delete)
      end

      def last_draft_content
        drafts.last.card_changes.last.value
      end

      def blank_content?
        content.blank? || content.strip.blank?
      end

      def nests?
        content_object.has_chunk? Content::Chunk::Nest
      end

      def content_object
        Card::Content.new content, self
      end
    end
  end
end
