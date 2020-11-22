def tr key, args={}
  args[:scope] ||= Card::Set.scope(caller)
  ::I18n.t key, args
end

format { delegate :tr, to: :card }
