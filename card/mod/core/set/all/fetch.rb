# = Card#fetch
#
# A multipurpose retrieval operator that integrates caching, database lookups,
# and "virtual" card construction
module ClassMethods
  # Look for cards in
  # * cache
  # * database
  # * virtual cards
  #
  # @param args [Integer, String, Card::Name, Symbol, Array]
  #    one or more of the three unique identifiers
  #      1. a numeric id (Integer)
  #      2. a name/key (String or Card::Name)
  #      3. a codename (Symbol)
  #    If you pass more then one mark or an array of marks they get joined with a '+'.
  #    The final argument can be a hash to set the following options
  #      :skip_virtual               Real cards only
  #      :skip_modules               Don't load Set modules
  #      :look_in_trash              Return trashed card objects
  #      :local_only                 Use only local cache for lookup and storing
  #      new: { opts for Card#new }  Return a new card when not found
  # @return [Card]
  def fetch *args
    mark, opts = normalize_fetch_args args
    validate_fetch_opts! opts

    card, needs_caching = retrieve_or_new mark, opts

    return if card.nil?
    write_to_cache card, opts[:local_only] if needs_caching
    standard_fetch_results card, mark, opts
  rescue ActiveModel::RangeError => _e
    return Card.new name: "card id out of range: #{mark}"
  end

  # fetch only real (no virtual) cards
  #
  # @param mark - see #fetch
  # @return [Card]
  def [] *mark
    fetch(*mark, skip_virtual: true)
  end

  # fetch real cards without set modules loaded. Should only be used for simple attributes
  # @example
  #   quick_fetch "A", :self, :structure
  #
  # @param mark - see #fetch
  # @return [Card]
  def quick_fetch *mark
    fetch mark, skip_virtual: true, skip_modules: true
  end

  # fetch only from the soft cache
  #
  # @param args - see #fetch
  # @return [Card]
  def fetch_soft *args
    mark, opts = normalize_fetch_args args
    fetch mark, opts.merge(local_only: true)
  end

  # @return [Card]
  def fetch_from_cast cast
    fetch_args = cast[:id] ? [cast[:id].to_i] : [cast[:name], { new: cast }]
    fetch *fetch_args
  end

  #----------------------------------------------------------------------
  # ATTRIBUTE FETCHING
  # The following methods optimize fetching of specific attributes

  def id cardish
    case cardish
    when Integer then cardish
    when Card then cardish.id
    when Symbol then Card::Codename.id cardish
    else fetch_id cardish
    end
  end

  # @param mark - see #fetch
  # @return [Integer]
  def fetch_id *mark
    mark, _opts = normalize_fetch_args mark
    return mark if mark.is_a? Integer
    card = quick_fetch mark.to_s
    card && card.id
  end

  # @param mark - see #fetch
  # @return [Card::Name]
  def fetch_name *mark
    if (card = quick_fetch(mark))
      card.name
    elsif block_given?
      yield.to_name
    end
  rescue ActiveModel::RangeError => _e
    block_given? ? yield.to_name : nil
  rescue Card::Error::CodenameNotFound => e
    block_given? ? yield.to_name : raise(e)
  end

  # @param mark - see #fetch
  # @return [Integer]
  def fetch_type_id *mark
    quick_fetch(mark)&.type_id
  end
end

#----------------------------------------------------------------------
# INSTANCE METHODS
# fetching from the context of a card

def fetch traits, opts={}
  opts[:new][:supercard] = self if opts[:new]
  Array.wrap(traits).inject(self) do |card, trait|
    Card.fetch card.name.trait(trait), opts
  end
end

def renew mark, new_opts
  return self if new_opts.blank?
  opts = new_opts.clone.merge name: mark
  copy = dup
  handle_default_content opts
  copy.newish opts
  copy
end

def newish opts
  Card.with_normalized_new_args opts do |norm_opts|
    handle_type norm_opts do
      assign_attributes norm_opts
      self.name = name # trigger superize_name
    end
  end
end

def handle_default_content opts
  return unless (default_content = opts.delete(:default_content)) && db_content.blank?

  opts[:content] ||= default_content
end

def refresh force=false
  return self unless force || frozen? || readonly?
  return unless id
  fresh_card = self.class.find id
  fresh_card.include_set_modules
  fresh_card
end
