def tr key, args={}
  Cardio.tr key, args.merge(caller: caller)
end

format do
  def tr key, args={}
    Cardio.tr key, args.merge(caller: caller)
  end
end
