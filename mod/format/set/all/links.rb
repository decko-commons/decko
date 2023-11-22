RESOURCE_TYPE_REGEXP = /^([a-zA-Z][\-+.a-zA-Z\d]*):/

# The #link_to methods support smart formatting of links in multiple formats.
format do
  # Creates a "link", the meaning of which depends upon the format.  In this base
  # format, the link looks like [text][absolute path]
  #
  # @param text [String] optional string associated with link
  # @param opts [Hash] optional Hash. In simple formats, :path is usually the only key
  def link_to text=nil, opts={}
    path = path((opts.delete(:path) || {}))
    if text && path != text
      "#{text}[#{path}]"
    else
      path
    end
  end

  # link to a different view of the current card
  # @param view [Symbol,String]
  # @param text [String]
  # @param opts [Hash]
  def link_to_view view, text=nil, opts={}
    add_to_path opts, view: view unless view == :home
    link_to text, opts
  end

  # link to a card other than the current card.
  # @param cardish [Integer, Symbol, String, Card]: A card identifier
  # @param text [String], optional: The text content of the link. Default is None.
  # @param opts [Hash], optional: Additional options for the link. Default is an empty hash
  # Returns:
  #   str: HTML markup for the generated link.
  def link_to_card cardish, text=nil, opts={}
    add_to_path opts, mark: Card::Name[cardish]
    link_to text, opts
  end

  # a "resource" is essentially a reference to something that
  # decko doesn't recognize to be a card.  Can be a remote url,
  # a local url (that decko hasn't parsed) or a local path.
  # @param resource [String]
  # @param text [String]
  # @param opts [Hash]
  def link_to_resource resource, text=nil, opts={}
    resource = clean_resource resource, resource_type(resource)
    link_to text, opts.merge(path: resource)
  end

  # smart_link_to is wrapper method for #link_to, #link_to_card, #link_to_view, and
  # #link_to_resource.  If the opts argument contains :view, :related, :card, or
  # :resource, it will use the respective method to render a link.
  #
  # This is usually most useful when writing views that generate many different
  # kinds of links.
  def smart_link_to text, opts={}
    if (linktype = %i[view card resource].find { |key| opts[key] })
      send "link_to_#{linktype}", opts.delete(linktype), text, opts
    else
      send :link_to, text, opts
    end
  end

  private

  def resource_type resource
    case resource
    when /^https?:/           then "external-link"
    when %r{^/}               then "internal-link"
    when /^mailto:/           then "email-link"
    when RESOURCE_TYPE_REGEXP then "#{Regexp.last_match(1)}-link"
    end
  end

  def clean_resource resource, resource_type
    if resource_type == "internal-link"
      # remove initial slash; #contextualize_path handles relative root
      contextualize_path resource.sub(%r{^/}, "")
    else
      resource
    end
  end

  # Adds key-value pairs from a new hash to the 'path' key in the given options dictionary.
  # @params opts [dict]: The options dictionary to be modified.
  # @params new_hash [dict]: The new hash containing key-value pairs to be added to the 'path'.
  # Returns:
  #   None
  def add_to_path opts, new_hash
    opts[:path] = (opts[:path] || {}).merge new_hash
  end
end

public

format :html do
  # in HTML, #link_to renders an anchor tag <a>
  # it treats opts other than "path" as html opts for that tag,
  # and it adds special handling of "remote" and "method" opts
  # (changes them into data attributes)
  def link_to text=nil, opts={}
    opts[:href] ||= path opts.delete(:path)
    text = raw(text || opts[:href])
    interpret_data_opts_to_link_to opts
    content_tag :a, text, opts
  end

  # in HTML, #link_to_card adds special css classes indicated whether a
  # card is "known" (real or virtual) or "wanted" (unknown)
  # TODO: upgrade from (known/wanted)-card to (real/virtual/unknown)-card
  def link_to_card cardish, text=nil, opts={}
    name = Card::Name[cardish]
    slotterify opts if opts[:slotter]
    add_known_or_wanted_class opts, name
    super name, (text || name), opts
  end

  # in HTML, #link_to_view defaults to a remote link with rel="nofollow".
  def link_to_view view, text=nil, opts={}
    slotterify opts
    super view, (text || view), opts
  end

  # in HTML, #link_to_resource automatically adds a target to external resources
  # so they will open in another tab. It also adds css classes indicating whether
  # the resource is internal or external
  def link_to_resource resource, text=nil, opts={}
    add_resource_opts opts, resource_type(resource)
    super
  end

  private

  def slotterify opts
    opts.delete(:slotter)
    opts.reverse_merge! remote: true, rel: "nofollow"
    add_class opts, "slotter"
  end

  def add_known_or_wanted_class opts, name
    known = opts.delete :known
    known = Card.known?(name) if known.nil?
    add_class opts, (known ? "known-card" : "wanted-card")
  end

  def interpret_data_opts_to_link_to opts
    %i[remote method].each do |key|
      next unless (val = opts.delete key)

      opts["data-#{key}"] = val
    end
  end

  def add_resource_opts opts, resource_type
    opts[:target] ||= "_blank" if resource_type == "external-link"
    add_class opts, resource_type
  end
end
