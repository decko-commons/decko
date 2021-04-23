def t key, args={}
  Cardio.t key, args
end

def tr key, args={}
  Cardio.tr key, args.merge(caller: caller)
end

format do
  def t key, args={}
    Cardio.t key, args
  end

  def tr key, args={}
    Cardio.tr key, args.merge(caller: caller)
  end
end
