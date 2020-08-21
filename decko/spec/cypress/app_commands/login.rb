user = command_options || "Joe Admin"
Card::Auth.signin Card.fetch_id(user)
