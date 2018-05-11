event :cache_expired_for_new_set, :store, on: :create do
  Card.follow_caches_expired
end