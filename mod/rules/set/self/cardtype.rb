format :html do
  view :grouped_list do
    All::CardtypeGroups::GROUP.keys.map do |group|
      type_list = group == "Custom" ? custom_types : All::CardtypeGroups::GROUP[group]
      next if type_list.empty?

      [wrap_with(:h5, group), wrap_with(:p, listing(type_list))]
    end.flatten.join "\n"
  end
end
