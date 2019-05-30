include_set Abstract::Filterable

before :bar do
  class_up "bar-body", "filterable"
  super()
end

before :expanded_bar do
  class_up "bar", "filterable"
  super()
end
