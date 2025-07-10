format do
  view :compact_missing, perms: :none, compact: true do
    ""
  end

  view :unknown, perms: :none, cache: :never do
    ""
  end

  view :server_error, perms: :none do
    t(:format_server_error)
  end

  view :denial, perms: :none do
    focal? ? t(:format_denial) : ""
  end

  view :not_found, perms: :none do
    error_name = card.name.present? ? safe_name : t(:format_not_found_no_name)
    t(:format_not_found_named, cardname: error_name)
  end

  view :bad_address, perms: :none do
    root.error_status = 404
    t(:format_bad_address)
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
    t :format_unsupported_view, view: view, cardname: card.name
  end
end

format :json do
  view :errors, perms: :none do
    {
      error_status: error_status,
      errors: card.errors.each_with_object({}) { |e, h| h[e.attribute] = e.message }
    }
  end

  view :server_error, :errors, perms: :none
  view :denial, :errors, perms: :none
  view :not_found, :errors, perms: :none
  view :bad_address, perms: :none do
    card.errors.add :address, super()
    render_errors
  end
end
