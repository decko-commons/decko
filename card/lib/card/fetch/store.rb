class Card
  class Fetch
    # lazy cache updates based on results
    module Store
      def update_cache
        return unless update_cache?

        card.prep_modules_for_caching unless skip_modules?
        Card.write_to_cache card, local_only?
      end

      def update_cache?
        (fresh_from_db? || new_for_cache || needs_prep?) && !card&.uncacheable?
      end

      def fresh_from_db?
        @fresh_from_db
      end

      # instantiate a card as a cache placeholder
      def new_for_cache
        return unless new_for_cache?

        args = { name: mark, skip_modules: true }
        args[:type_lookup] = :skip if skip_type_lookup?
        args.merge! new_opts.slice(:type, :type_id, :type_code) if eager_caching?
        @card = Card.new args
      end

      def eager_caching?
        opts[:eager_cache] && mark.name? && mark.absolute? && new_opts.present?
      end

      def new_for_cache?
        reusable? && new_card_needed?
      end

      def needs_prep?
        return unless card.present?

        !(skip_modules? || card.patterns?)
      end

      def new_card_needed?
        !(card.present? && (card.type_id.present? || skip_type_lookup?))
      end

      def reusable?
        !(mark.is_a?(Integer) || (mark.blank? && !opts[:new]))
      end
    end
  end
end
