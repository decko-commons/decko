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
    opts = Env.hash args[:card]
    opts[:type] ||= args[:type] if args[:type]
    # for /new/:type shortcut.  we should handle in routing and deprecate this
    opts[:name] ||= Card::Name.url_key_to_standard args[:mark]
    opts
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
    else
      card.assign_name_from_fetched_mark! mark, opts
    end
    #
    finalize_fetch_results card, opts
    # must include_set_modules before checking `card.known?`,
    # in case, eg, set modules override #virtual?
    card if new_opts || card.known?
  end

  def finalize_fetch_results card, opts
    card.include_set_modules unless opts[:skip_modules]
    card
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
