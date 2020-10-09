format do
  # Decko uses "path" a bit unusually.  In most formats, it returns a full url.  In HTML,
  # it provides everything after the domain/port.
  #
  # If you're feeling your saucy oats, you might point out that typically "paths" don't
  # include queries and fragment identifiers, much less protocols, domains, and ports.
  # 10 pedantry points to you! But "path" has just four letters and is smart about
  # format needs, so using it will lead you down the right ... something or other.

  # Format#path is for generating standard card routes, eg, assuming the card
  # associated with the current format is named "current", it will generate paths like
  # these:

  #   path view: :bar   -> "current?view=bar"
  #   path mark: [mycardid] -> "mycardname"
  #   path format: :csv)    -> "current.csv"
  #   path action: :update  -> "update/current"

  # #path produces paths that follow one of three main patterns:

  #   1. mark[.format][?query]  # standard GET request
  #   2. action/mark[?query]    # GET variant of standard actions
  #   3. new/mark               # shortcut for "new" view of cardtype

  # @param opts [Hash, String] a String is treated as a complete path and
  # bypasses all processing
  # @option opts [String, Card::Name, Integer, Symbol, Card] :mark
  # @option opts [Symbol] :action card action (:create, :update, :delete)
  # @option opts [Symbol] :format
  # @option opts [Hash] :card
  # @option opts [TrueClass] :no_mark

  CAST_PARAMS = { slot: { hide: :array, show: :array, wrap: :array } }.freeze
  # TODO: monkey API for this

  def path opts={}
    return opts unless opts.is_a? Hash
    path = new_cardtype_path(opts) || standard_path(opts)
    contextualize_path path
  end

  # in base format (and therefore most other formats), even internal paths
  # are rendered as absolute urls.
  def contextualize_path relative_path
    card_url relative_path
  end

  private

  def new_cardtype_path opts
    return unless valid_opts_for_new_cardtype_path? opts
    "#{opts.delete :action}/#{path_mark opts}#{path_query opts}"
  end

  def valid_opts_for_new_cardtype_path? opts
    return unless opts[:action].in? %i[new type]

    # "new" and "type" are not really an action and are only
    # a valid value here for this path
    opts[:mark].present?
  end

  def standard_path opts
    path_base(opts) + path_extension(opts) + path_query(opts)
  end

  def path_base opts
    mark = path_mark opts
    if (action = path_action opts)
      action_base action, mark
    else
      mark
    end
  end

  def action_base action, mark
    mark.present? ? "#{action}/#{mark}" : "card/#{action}"
    # the card/ prefix prevents interpreting action as cardname
  end

  def path_action opts
    return unless (action = opts.delete(:action)&.to_sym)
    %i[create update delete].find { |a| a == action }
  end

  def path_mark opts
    return "" if markless_path? opts
    name = opts[:mark] ? Card::Name[opts.delete(:mark)] : card.name
    add_unknown_name_to_opts name.to_name, opts
    name.to_name.url_key
  end

  def markless_path? opts
    opts[:action] == :create || opts.delete(:no_mark)
  end

  def path_extension opts
    extension = opts.delete :format
    extension ? ".#{extension}" : ""
  end

  def path_query opts
    opts = cast_path_opts opts
    opts.empty? ? "" : "?#{opts.to_param}"
  end

  # normalizes certain path opts to specified data types
  def cast_path_opts opts, cast_hash=nil
    cast_hash ||= CAST_PARAMS
    return opts unless opts.is_a?(::Hash)
    opts.each do |key, value|
      next unless (cast_to = cast_hash[key])
      opts[key] = cast_path_value value, cast_to
    end
  end

  def cast_path_value value, cast_to
    if cast_to.is_a? Hash
      cast_path_opts value, cast_to
    else
      send "cast_path_value_as_#{cast_to}", value
    end
  end

  def cast_path_value_as_array value
    Array.wrap value
  end

  def add_unknown_name_to_opts name, opts
    return if name_specified?(opts) || name_standardish?(name) || Card.known?(name)
    opts[:card] ||= {}
    opts[:card][:name] = name
  end

  def name_specified? opts
    opts[:card] && opts[:card][:name]
  end

  # no name info will be lost by using url_key
  def name_standardish? name
    name.s == Card::Name.url_key_to_standard(name.url_key)
  end
end

format :json do
  def add_unknown_name_to_opts name, opts
    # noop
  end
end

format :css do
  def contextualize_path relative_path
    if Cardio.config.file_storage == :local
      # absolute paths lead to invalid assets path in css for cukes
      card_path relative_path
    else
      # ...but relative paths are problematic when machine output and
      # hard-coded assets (like fonts) are on different servers
      card_url relative_path
    end
  end
end

format :html do
  # in HTML, decko paths rendered as relative to the site's root.
  def contextualize_path relative_path
    card_path relative_path
  end
end

format :email_html do
  def contextualize_path relative_path
    card_url relative_path
  end
end
