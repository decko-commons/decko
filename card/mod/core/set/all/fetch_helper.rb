
module ClassMethods

  # a fetch method to support the needs of the card controller.
  # should be in Decko?
  def controller_fetch args
    opts = controller_fetch_opts args
    if args[:action] == "create"
      # FIXME: we currently need a "new" card to catch duplicates
      # (otherwise save will just act like a normal update)
      # We may need a "#create" instance method to handle this checking?
      Card.new opts
    else
      mark = args[:id] || opts[:name]
      Card.fetch mark, look_in_trash: args[:look_in_trash], new: opts
    end
  end

  private

  def controller_fetch_opts args
    opts =
        # clone doesn't work for Parameters
        if args[:card].respond_to?(:to_unsafe_h)
          args[:card].to_unsafe_h
        else
          (args[:card] || {}).clone
        end
    # clone so that original params remain unaltered.  need deeper clone?
    opts[:type] ||= args[:type] if args[:type]
    # for /new/:type shortcut.  we should handle in routing and deprecate this
    opts[:name] ||= Card::Name.url_key_to_standard(args[:id])
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

  def retrieve_existing mark, opts
    return [nil, false] unless mark.present?
    mark_type, mark_key = retrievable_mark_type_and_value mark
    needs_caching = false # until proven true :)

    # look in cache
    card = send "retrieve_from_cache_by_#{mark_type}", mark_key, opts[:local_only]

    if retrieve_from_db?(card, opts)
      # look in db if needed
      card = retrieve_from_db mark_type, mark_key, opts
      needs_caching = !card.nil? && !card.trash
    end

    [card, needs_caching]
  end

  def retrievable_mark_type_and_value mark
    # return mark_type and mark_value
    if mark.is_a? Integer
      [:id, mark]
    else
      [:key, mark.key]
    end
  end

  def retrieve_from_db? card, opts
    card.nil? || (opts[:look_in_trash] && card.new_card? && !card.trash)
  end

  def retrieve_from_db mark_type, mark_key, opts
    query = { mark_type => mark_key }
    query[:trash] = false unless opts[:look_in_trash]
    card = Card.where(query).take
    card
  end

  def standard_fetch_results card, mark, opts
    if card.new_card?
      new_card_fetch_results card, mark, opts
    else
      finalize_fetch_results card, opts
    end
  end

  def new_card_fetch_results card, mark, opts
    case
      when opts[:new].present? then return card.renew(opts)
      when opts[:new] # noop for empty hash
      when opts[:skip_virtual] then return nil
    end
    card.assign_name_from_fetched_mark! mark, opts
    finalize_fetch_results card, opts
    card if opts[:new] || card.known?
  end

  def finalize_fetch_results card, opts
    card.include_set_modules unless opts[:skip_modules]
    card
  end

  def normalize_fetch_args args
    opts = args.last.is_a?(Hash) ? args.pop : {}
    mark = compose_mark args
    mark = absolutize_fetch_mark mark, opts.dig(:new, :supercard)
    [mark, opts]
  end

  def absolutize_fetch_mark mark, supercard
    return mark unless mark.is_a?(Card::Name) && supercard
    mark.to_name.absolute_name supercard.name
  end

end

public

def assign_name_from_fetched_mark! mark, opts
  return if opts[:local_only]
  return unless mark && mark.to_s != name
  self.name = mark.to_s
end
