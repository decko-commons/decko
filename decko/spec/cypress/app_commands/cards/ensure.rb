name = command_options.try(:[], "name")
content = command_options.try(:[], "content")
type = command_options.try(:[], "type")
args = command_options.try(:[], "args")

Class.new do
  extend Card::Model::SaveHelper
  args ||= {}
  args[:content] = content if content
  args[:type] = type if type
  args[:name] = name if name
  Card::Auth.as_bot { Card.ensure args }
end
