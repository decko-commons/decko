class Card
  class Fetch
    # retrieval and instantiation methods for Card::Fetch
    module Retrieve
      # look for card in cache.  if that doesn't work, look in database
      def retrieve_existing
        return unless mark.present?

        retrieve_from_cache || retrieve_from_db
      end

      def retrieve_from_cache
        @card = Card.send "retrieve_from_cache_by_#{mark_type}",
                          mark_value, @opts[:local_only]
        @card = nil if card&.new? && look_in_trash?
        # don't return cached cards if looking in trash -
        # we want the db version
        card
      end

      def retrieve_from_db
        query = retrieval_from_db_query
        @card = query ? Card.where(query).take : nil
        @fresh_from_db = true if card.present? && !card.trash
        card
      end

      def retrieval_from_db_query
        return unless (query = retrieval_from_db_query_base)

        query[:trash] = false unless look_in_trash?
        query
      end

      def retrieval_from_db_query_base
        if mark_type == :key && mark.simple?
          { key: mark_value }
        elsif (id = id_from_mark)
          { id: id }
        end
      end

      def id_from_mark
        mark_type == :id ? mark_value : Lexicon.id(mark_value)
      end

      # In both the cache and the db, ids and keys are used to retrieve card data.
      # These methods identify the kind of mark to use and its value
      def mark_type
        @mark_type ||= mark.is_a?(Integer) ? :id : :key
      end

      def mark_value
        @mark_value ||= mark.is_a?(Integer) ? mark : mark.key
      end
    end
  end
end
