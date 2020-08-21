Class.new do
  extend Card::Model::SaveHelper
  Card::Auth.as_bot do
    ensure_card "snow", type: :basic
    ensure_card "ice", type: :basic
    ensure_card "menu", content: ""
    delete_card "rain"
  end
end
