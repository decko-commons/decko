
def fetch_params params
  Env.params.select { |key, val| val && params.include?(key) }
     .with_indifferent_access
end

def param_to_i key, default
  if (value = Env.params[key])
    value.to_i
  else
    default
  end
end
