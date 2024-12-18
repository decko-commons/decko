# -*- encoding : utf-8 -*-

include_set Abstract::CoffeeScript

event :validate_coffeescript_syntax, :validate, on: :save, changed: %i[type_id content] do
  CoffeeScript.compile content
rescue ExecJS::RuntimeError => e
  errors.add :content, e.message.remove("[stdin]:")
end
