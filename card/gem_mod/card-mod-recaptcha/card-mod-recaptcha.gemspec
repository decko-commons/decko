# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "recaptcha"

  s.summary       = "recaptcha support for decko"
  s.description   = ""
  s.files         = Dir["{config,set}/**/*"]

  s.add_runtime_dependency "recaptcha", "~> 4.13.1"
end
