# TODO: Use codenames instead of names
GROUP = {
  "Text" => %w[RichText PlainText Markdown Phrase HTML],
  "Data" => %w[Number Toggle Date URI],
  "Upload" => %w[File Image],
  "Custom" => [],
  "Organize" => ["List", "Pointer", "Search", "Link list", "Nest list"],
  "Template" => ["Notification template", "Email template", "Twitter template"],
  "Admin" => ["Cardtype", "User", "Role", "Sign up", "Session", "Set", "Setting"],
  "Styling" => ["Layout", "Skin", "Bootswatch skin", "Customized bootswatch skin",
                "CSS", "SCSS"],
  "Scripting" => %w[JSON JavaScript CoffeeScript]
}.freeze

# DEFAULT_RULE_GROUPS = ["Text", "Data", "Upload", "Organize - Search"]
# STRUCTURE_RULE_GROUPS = ["Text", "Organize > Search"]

# group for each cardtype: { "RichText => "Content", "Layout" => "Admin", ... }
GROUP_MAP = GROUP.each_with_object({}) do |(cat, types), h|
  types.each { |t| h[t] = cat }
end

format :html do
  def custom_types
    custom_types = []

    Auth.createable_types.each do |type|
      custom_types << type unless All::CardtypeGroups::GROUP_MAP[type]
    end

    custom_types
  end
end
