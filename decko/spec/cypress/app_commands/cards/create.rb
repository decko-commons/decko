name = command_options.try(:[], "name")
content = command_options.try(:[], "content")

Card.create! name: name, content: content
