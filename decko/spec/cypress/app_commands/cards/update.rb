name = command_options.try(:[], "name")
content = command_options.try(:[], "content")

Card[name].update! content: content
