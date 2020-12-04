def tr key, args={}
  args[:scope] ||= Card::Set.scope(caller)
  ::I18n.t key, args
end

format do
  def tr key, args={}
    args[:scope] ||= Card::Set.scope(caller)
    ::I18n.t key, args
  end
end
