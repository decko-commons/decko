# remove set members from all lists that reference them upon deletion
event :delist, :prepare_to_store, on: :delete do
  referers.each do |referer|
    next unless referer.is_a? Abstract::List
    referer.drop_item name
    subcard referer
  end
end
