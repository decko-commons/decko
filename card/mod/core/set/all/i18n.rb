
def tr key, args={}
  ::I18n.t key, args.merge(scope: Card::Set.scope(caller))
end

format do
  def tr key, args={}
    ::I18n.t key, args.reverse_merge(scope: Card::Set.scope(caller))
  end
end
