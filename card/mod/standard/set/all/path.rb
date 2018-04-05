format do
  # Decko uses "path" a bit unusually.  In most formats, it returns a full url.  In HTML,
  # it provides everything after the domain/port.
  #
  # If you're feeling your saucy oats, you might point out that typically a "path" does not
  # include queries and fragment identifiers, much less protocols, domains, and ports.
  # 10 pedantry points to you! But "path" has just four letters and, because it's smart about
  # format needs, using it will lead you down the right ... something or other.

  # Format#path is for generating standard card routes, eg, assuming the card
  # associated with the current format is named "current", it will generate paths like
  # these:

  #   path view: :listing   -> "current?view=listing"
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
  # @option opts [Hash] :card
  # @option opts []
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
    return unless opts[:action] == :new
    opts.delete :action
    return unless opts[:mark]
    "new/#{path_mark opts}#{path_query opts}"
  end

  def standard_path opts
    path_base(opts) + path_extension(opts) + path_query(opts)
  end

  def path_base opts
    mark = path_mark opts
    if (action = path_action opts)
      mark.present? ? "#{action}/#{mark}" : "card/#{action}"
      # the card/ prefix prevents interpreting action as cardname
    else
      mark
    end
  end

  def path_action opts
    return unless (action = opts.delete(:action)&.to_sym)
    %i[create update delete].find { |a| a == action }
  end

  def path_mark opts
    return "" if opts[:action] == :create || opts.delete(:no_mark)
    name = opts[:mark] ? Card::Name[opts.delete(:mark)] : card.name
    add_unknown_name_to_opts name.to_name, opts
    name.to_name.url_key
  end

  def path_extension opts
    extension = opts.delete :format
    extension ? ".#{extension}" : ""
  end

  def path_query opts
    opts.empty? ? "" : "?#{opts.to_param}"
  end
end

public

format :html do
  # in HTML, decko paths rendered as relative to the site's root.
  def contextualize_path relative_path
    card_path relative_path
  end
end
