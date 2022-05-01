assign_type :list

event :follow_fields_changed, :integrate do
  Card.follow_caches_expired
end
