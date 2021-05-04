def alias?
  return false if simple? # overridden in type/alias

  name.parts.any? { |p| Card[p]&.alias? }
end
