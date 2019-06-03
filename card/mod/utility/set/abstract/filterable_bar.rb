include_set Abstract::Filterable

before :bar do
  class_up "bar-body", "_filterable"
  super()
end

before :expanded_bar do
  class_up "bar", "_filterable"
  super()
end
