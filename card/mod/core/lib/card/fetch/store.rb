class Card
  class Fetch
    # lazy cache updates based on results
    module Store
      def update_cache
        return unless update_cache?

        prep_for_cache
        Card.write_to_cache card, local_only?
      end

      def update_cache?
        (cache_ready? || new_for_cache || needs_prep?) && !card&.uncacheable?
      end

      def cache_ready?
        @cache_ready
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

      # Because Card works by including set-specific ruby modules on singleton classes and
      # singleton classes generally can't be cached, we can never cache the cards in a
      # completely ready-to-roll form.
      #
      # However, we can optimize considerably by saving the list of ruby modules in
      # environments where they won't be changing (eg production) or at least the list of
      # matching set patterns
      def prep_for_cache
        # return # DELETE ME
        return if skip_modules?

        Card.config.cache_set_module_list ? card.set_modules : card.patterns
      end
    end
  end
end
