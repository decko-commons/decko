class Card
  class Fetch
    # polishing fetch results
    module Results
      def results
        return if card.nil?
        Card.write_to_cache card, local_only? if needs_caching?
        card.new_card? ? new_result_card : finalize_result_card
      end

      def finalize_result_card
        card.include_set_modules unless opts[:skip_modules]
        card
      end

      def new_result_card
        if (new_opts = opts[:new])
          @card = card.renew mark, new_opts
        elsif opts[:skip_virtual]
          return nil
        else
          assign_name_from_mark
        end
        finalize_result_card
        # must include_set_modules before checking `card.known?`,
        # in case, eg, set modules override #virtual?
        card if new_opts || card.known?
      end

      def assign_name_from_mark
        return if opts[:local_only]
        return unless mark&.to_s != card.name
        card.name = mark.to_s
      end

      # Because Card works by including set-specific ruby modules on singleton classes and
      # singleton classes generally can't be cached, we can never cache the cards in a
      # completely ready-to-roll form.
      #
      # However, we can optimize considerably by saving the list of ruby modules in
      # environments where they won't be changing (eg production) or at least the list of
      # matching set patterns
      def prep_for_cache
        Cardio.config.cache_set_module_list ? set_modules : patterns
      end
    end
  end
end
