name = command_options.try(:[], "name")
content = command_options.try(:[], "content")
type = command_options.try(:[], "type")
args = command_options.try(:[], "args")

Class.new do
  args ||= {}
  args[:content] = content if content
  args[:type] = type if type
  args[:name] = name if name
  Card::Auth.as_bot { Card.ensure args }
end
