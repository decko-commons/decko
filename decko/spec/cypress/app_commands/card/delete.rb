Card::Auth.as_bot do
  name = command_options
  return unless Card.exist?(name)

  Card[name].delete!
end
