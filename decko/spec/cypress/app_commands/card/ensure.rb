name = command_options.try(:[], 'name')
content = command_options.try(:[], 'content')

Class.new do
  extend Card::Model::SaveHelper
  ensure_card name, content: content
end
