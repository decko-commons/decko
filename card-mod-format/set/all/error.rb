format do
  view :compact_missing, perms: :none, compact: true do
    ""
  end

  view :unknown, perms: :none, cache: :never do
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
    ["Problem:", "", error_messages].flatten.join "\n"
  end

  def error_messages
    card.errors.map do |error|
      if error.attribute == :abort
        simple_error_message error.message
      else
        standard_error_message error
      end
    end
  end

  # for override
  def simple_error_message message
    message
  end

  # for override
  def standard_error_message error
    "#{error.attribute.to_s.upcase}: #{error.message}"
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
