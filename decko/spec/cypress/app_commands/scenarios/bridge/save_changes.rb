Class.new do
  extend Card::Model::SaveHelper
  Card::Auth.as_bot do
    Card.ensure name: "snow", type: :basic
    Card.ensure name: "ice", type: :basic
    Card.ensure name: "menu", content: ""
    delete_card "rain"
  end
end
