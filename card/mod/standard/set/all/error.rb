def copy_errors card
  card.errors.each do |att, msg|
    errors.add att, msg
  end
end

format do
  view :closed_missing, perms: :none, closed: true do
    ""
  end

  view :missing, perms: :none do
    ""
  end

  view :server_error, perms: :none do
    tr(:server_error)
  end

  view :denial, perms: :none do
    focal? ? tr(:denial) : ""
  end

  view :not_found, perms: :none do
    error_name = card.name.present? ? safe_name : tr(:not_found_no_name)
    tr(:not_found_named, cardname: error_name)
  end

  view :unsupported_view, perms: :none, tags: :unknown_ok do
    tr(:unsupported_view, view: voo.unsupported_view, cardname: error_cardname)
  end

  view :too_slow, perms: :none, closed: true do
    tr(:too_slow, showname: title_in_context)
  end

  view :bad_address, perms: :none do
    raise Card::Error::OpenError, tr(:bad_address)
  end

  view :error_test do
    subformat(card).render :error_test
  end
end

format :json do
  view :errors do
    { error_status: error_status,
      errors: error_list }
  end

  def error_list
    card.errors.each_with_object([]) do |(field, message), list|
      list << { field: field, message: message }
    end
  end

  view :server_error, :errors
  view :denial, :errors
  view :too_slow, :errors
end
