GROUP = {
  "Content" => %w[RichText PlainText Phrase Date Number Toggle Markdown File Image URI],
  "Custom" => [],
  "Organize" => ["Cardtype", "Search", "List", "Link list", "Pointer",
                 "Mirror List", "Mirrored List"],
  "Template" => [ "Notification template", "Email template", "Twitter template"],
  "Admin" => ["User", "Role", "Sign up", "Session", "Set", "Setting"],
  "Styling" => ["Layout", "Skin", "Bootswatch skin", "Customized bootswatch skin", "CSS", "SCSS"],
  "Code" => %w[HTML JSON JavaScript CoffeeScript]
}.freeze

# group for each cardtype: { "RichText => "Content", "Layout" => "Admin", ... }
GROUP_MAP = GROUP.each_with_object({}) do |(cat, types), h|
  types.each { |  t| h[t] = cat }
end

format :html do
  view :grouped_list do
    GROUP.keys.map do |group|
      type_list = group == "Custom" ? custom_types : GROUP[group]
      next if type_list.empty?

      [wrap_with(:h5, group), wrap_with(:p, listing(type_list))]
    end.flatten.join "\n"
  end

  def custom_types
    custom_types = []

    Card.search(type_id: CardtypeID, return: "name").each do |name|
      next if Self::Cardtype::GROUP_MAP[name]

      custom_types << name
    end
    custom_types
  end
end