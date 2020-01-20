module ClassMethods
  # a fetch method to support the needs of the card controller.
  # should be in Decko?
  def controller_fetch args
    card_opts = controller_fetch_opts args
    if args[:action] == "create"
      # FIXME: we currently need a "new" card to catch duplicates
      # (otherwise save will just act like a normal update)
      # We may need a "#create" instance method to handle this checking?
      Card.new card_opts
    else
      standard_controller_fetch args, card_opts
    end
  end

  def safe_param param
    if param.respond_to? :to_unsafe_h
      # clone doesn't work for Parameters
      param.to_unsafe_h
    else
      # clone so that original params remain unaltered.  need deeper clone?
      (param || {}).clone
    end
  end

  private

  def standard_controller_fetch args, card_opts
    mark = args[:mark] || card_opts[:name]
    card = Card.fetch mark, skip_modules: true,
                            look_in_trash: args[:look_in_trash],
                            new: card_opts
    card.assign_attributes card_opts if args[:assign] && card&.real?
    card&.include_set_modules
    card
  end

  def controller_fetch_opts args
    opts = safe_param args[:card]
    opts[:type] ||= args[:type] if args[:type]
    # for /new/:type shortcut.  we should handle in routing and deprecate this
    opts[:name] ||= Card::Name.url_key_to_standard(args[:mark])
    opts
  end

  def validate_fetch_opts! opts
    return unless opts[:new] && opts[:skip_virtual]
    raise Card::Error, "fetch called with new args and skip_virtual"
  end

  def skip_type_lookup? opts
    # if opts[:new] is not empty then we are initializing a variant that is
    # different from the cached variant
    # and can postpone type lookup for the cached variant
    # if skipping virtual no need to look for actual type
    opts[:skip_virtual] || opts[:new].present? || opts[:skip_type_lookup]
  end

  def retrieve_or_new mark, opts
    card, needs_caching = retrieve_existing mark, opts
    if (new_card = new_for_cache card, mark, opts)
      [new_card, true]
    else
      [card, needs_caching]
    end
  end

  # look in cache.  if that doesn't work, look in database
  # @return [{Card}, {True/False}] Card object and "needs_caching" ruling
  def retrieve_existing mark, opts
    return [nil, false] unless mark.present?
    mark_type, mark_key = retrievable_mark_type_and_value mark
    if (card = retrieve_from_cache_by_mark mark_type, mark_key, opts)
      # we have an acceptable card in the cache
      # (and don't need to cache it again!)
      [card, false]
    else
      # try to find the card in the database
      card = retrieve_from_db mark_type, mark_key, opts[:look_in_trash]
      [card, !(card.nil? || card.trash)]
    end
  end

  def retrieve_from_cache_by_mark mark_type, mark_key, opts
    card = send "retrieve_from_cache_by_#{mark_type}", mark_key, opts[:local_only]
    return_cached_card?(card, opts[:look_in_trash]) ? card : nil
  end

  # In both the cache and the db, ids and keys are used to retrieve card data.
  # This method identifies the kind of mark to use and its value
  # @return [Array] first item is :id or :key, second is corresponding value
  def retrievable_mark_type_and_value mark
    # return mark_type and mark_value
    if mark.is_a? Integer
      [:id, mark]
    else
      [:key, mark.key]
    end
  end

  def return_cached_card? card, look_in_trash
    return false unless card
    card.real? || !look_in_trash
  end

  # @return [Card, nil] Card object
  def retrieve_from_db mark_type, mark_key, look_in_trash=false
    query = { mark_type => mark_key }
    query[:trash] = false unless look_in_trash
    Card.where(query).take
  end

  def standard_fetch_results card, mark, opts
    if card.new_card?
      new_card_fetch_results card, mark, opts
    else
      finalize_fetch_results card, opts
    end
  end

  def new_card_fetch_results card, mark, opts
    if (new_opts = opts[:new])
      card = card.renew mark, new_opts
    elsif opts[:skip_virtual]
      return nil
    end
    card.assign_name_from_fetched_mark! mark, opts
    finalize_fetch_results card, opts
    # must include_set_modules before checking `card.known?`,
    # in case, eg, set modules override #virtual?
    card if new_opts || card.known?
  end

  def finalize_fetch_results card, opts
    card.include_set_modules unless opts[:skip_modules]
    card
  end

  def normalize_fetch_args args
    opts = args.last.is_a?(Hash) ? args.pop : {}
    mark = id_or_name args
    mark = absolutize_fetch_mark mark, opts.dig(:new, :supercard)
    [mark, opts]
  end

  def absolutize_fetch_mark mark, supercard
    return mark unless mark.name? && supercard
    mark.to_name.absolute_name supercard.name
  end
end

public

def assign_name_from_fetched_mark! mark, opts
  return if opts[:local_only]
  return unless mark && mark.to_s != name
  self.name = mark.to_s
end
