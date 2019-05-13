def copy_errors card
  card.errors.each do |att, msg|
    errors.add att, msg
  end
end

format do
  view :closed_missing, perms: :none, closed: true do
    ""
  end

  view :missing, perms: :none, cache: :never do
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

  view :bad_address, perms: :none do
    root.error_status = 404
    tr(:bad_address)
  end

  view :errors do
    ["Problem:", "", standard_errors].flatten.join "\n"
  end

  def standard_errors
    card.errors.map do |attrib, msg|
      attrib == :abort ? msg : standard_error_message(attrib, msg)
    end
  end

  # for override
  def standard_error_message attribute, message
    "#{attribute.to_s.upcase}: #{message}"
  end

  def unsupported_view_error_message view
    tr(:unsupported_view, view: view, cardname: card.name)
  end
end

format :json do
  view :errors do
    format_error error_list
  end

  view :server_error, :errors
  view :denial, :errors
  view :not_found, :errors

  view :bad_address do
    format_error super()
  end

  def format_error error
    { error_status: error_status, errors: error }
  end

  def error_list
    card.errors.each_with_object([]) do |(field, message), list|
      list << { field: field, message: message }
    end
  end
end
