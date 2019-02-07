name = command_options.try(:[], 'name')
content = command_options.try(:[], 'content')
type = command_options.try(:[], 'type')

Class.new do
  extend Card::Model::SaveHelper
  args = {}
  args[:content] = content if content
  args[:type] = type if type
  ensure_card name, args
end
