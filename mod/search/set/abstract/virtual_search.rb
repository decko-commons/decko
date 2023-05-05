include_set Abstract::CodeContent

def virtual?
  new?
end

def self.included klass
  klass.assign_type :search_type
end

# TODO: make cql content visible in editor
# format :html do
#   view :input do
#     super() + card.cql_content.to_s
#   end
# end
