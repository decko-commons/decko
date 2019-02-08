name = command_options
return unless Card.exist?(name)

Card::Auth.as_bot do
  Card[name].delete!
end
