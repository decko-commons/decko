Class.new do
  extend Card::Model::SaveHelper
  ensure_card "Two Header", "<h1>I'm a header</h1><h1>me too</h1>"
  ensure_card "Three Headers", "<h1>I'm a header</h1><h2>Me too</h2><h1>same here</h1>"
end
