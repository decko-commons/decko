class Card
  # retrieve card from cache or database, or (where needed) instantiate new card
  class Fetch
    attr_reader :card, :mark, :opts

    # see arg options in all/fetch
    def initialize *args
      normalize_args args
      absolutize_mark
      validate_opts!
      @needs_caching = false
    end

    def retrieve_or_new
      retrieve_existing
      new_for_cache
      results
    end

    def needs_caching?
      @needs_caching
    end

    def local_only?
      opts[:local_only]
    end

    def normalize_args args
      @opts = args.last.is_a?(Hash) ? args.pop : {}
      @mark = Card.id_or_name args
    end

    def absolutize_mark
      return unless mark.name? && (supercard = opts.dig(:new, :supercard))
      @mark = mark.absolute_name supercard.name
    end

    def validate_opts!
      return unless opts[:new] && opts[:skip_virtual]
      raise Card::Error, "fetch called with new args and skip_virtual"
    end

    # look in cache.  if that doesn't work, look in database
    # @return [{Card}, {True/False}] Card object and "needs_caching" ruling
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

    def look_in_trash?
      @opts[:look_in_trash]
    end

    def retrieve_from_db
      query = { mark_type => mark_value }
      query[:trash] = false unless look_in_trash?
      @card = Card.where(query).take
      @needs_caching = true if card.present? && !card.trash
      card
    end

    # In both the cache and the db, ids and keys are used to retrieve card data.
    # These methods identify the kind of mark to use and its value
    def mark_type
      @mark_type ||= mark.is_a?(Integer) ? :id : :key
    end

    def mark_value
      @mark_value ||= mark.is_a?(Integer) ? mark : mark.key
    end

    # instantiate a card as a cache placeholder
    def new_for_cache
      return unless new_for_cache?
      @needs_caching = true
      @card = Card.new name: mark, skip_modules: true,
                       skip_type_lookup: skip_type_lookup?
    end

    def new_for_cache?
      return false if mark.is_a?(Integer) || (mark.blank? && !opts[:new])
      return false if card && (card.type_known? || skip_type_lookup?)
      true
    end

    def skip_type_lookup?
      # if opts[:new] is not empty then we are initializing a variant that is
      # different from the cached variant
      # and can postpone type lookup for the cached variant
      # if skipping virtual no need to look for actual type
      opts[:skip_virtual] || opts[:new].present? || opts[:skip_type_lookup]
    end

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
    # However, we can optimize considerably by saving the list of ruby modules in environments
    # where they won't be changing (eg production) or at least the list of matching set
    # patterns in e
    def prep_for_cache
      Cardio.config.cache_set_module_list ? set_modules : patterns
    end
  end
end
