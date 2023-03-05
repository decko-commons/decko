Class.new do
  Card::Auth.as_bot do
    Card.ensure name: "snow", type: :basic
    Card.ensure name: "ice", type: :basic
    Card.ensure name: "menu", content: ""
    Card["rain"]&.delete!
  end
end
