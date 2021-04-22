module ClassMethods
  def retrieve_from_cache cache_key, local_only=false
    return unless cache
    local_only ? cache.soft.read(cache_key) : cache.read(cache_key)
  end

  def retrieve_from_cache_by_id id, local_only=false
    key = Card::Lexicon.name(id)&.key
    return unless key.present?

    retrieve_from_cache key, local_only if key
  end

  def retrieve_from_cache_by_key key, local_only=false
    retrieve_from_cache key, local_only
  end

  def write_to_cache card, local_only=false
    if local_only
      write_to_soft_cache card
    elsif cache
      cache.write card.key, card
    end
  end

  def write_to_soft_cache card
    return unless cache
    cache.soft.write card.key, card
  end

  def expire name
    key = name.to_name.key
    return unless (card = Card.cache.read key)
    card.expire
  end
end

def update_soft_cache
  Card.write_to_soft_cache self
end

def expire_pieces
  name.piece_names.each do |piece|
    Card.expire piece
  end
end

def expire cache_type=nil
  return unless (cache_class = cache_class_from_type cache_type)
  expire_views
  expire_names cache_class
  expire_id cache_class
end

def cache_class_from_type cache_type
  cache_type ? Card.cache.send(cache_type) : Card.cache
end

def view_cache_clean?
  !db_content_changed?
end

def view_cache_keys key_root=key
  @view_cache_keys ||= {}
  @view_cache_keys[key_root] ||= hard_read_view_cache_keys(key_root) || []
end

def ensure_view_cache_key cache_key
  return if view_cache_keys.include? cache_key

  @view_cache_keys[key] << cache_key
  hard_write_view_cache_keys
end

def hard_read_view_cache_keys key_root=key
  Card.cache.hard&.read_attribute key_root, :view_cache_keys
end

def hard_write_view_cache_keys key_root=key
  # puts "WRITE VIEW CACHE KEYS (#{name}): #{view_cache_keys}"
  Card.cache.hard&.write_attribute key_root, :view_cache_keys, view_cache_keys(key_root)
end

def expire_views
  each_key_version do |key|
    # puts "EXPIRE VIEW CACHE (#{name}): #{view_cache_keys}"
    view_keys = view_cache_keys key
    next unless view_keys.present?
    expire_view_cache_keys view_keys

    @view_cache_keys[key] = []
    hard_write_view_cache_keys key
  end
end

def expire_view_cache_keys view_keys
  Array.wrap(view_keys).each do |view_key|
    Card::View.cache.delete view_key
  end
end

def each_key_version
  [name, name_before_act].uniq.compact.each do |name_version|
    yield name_version.to_name.key
  end
end

def expire_names cache
  each_key_version do |key_version|
    expire_name key_version, cache
  end
end

def expire_name name_version, cache
  return unless name_version.present?
  key_version = name_version.to_name.key
  return unless key_version.present?
  cache.delete key_version
end

def expire_id cache
  return unless id.present?
  cache.delete "~#{id}"
end
