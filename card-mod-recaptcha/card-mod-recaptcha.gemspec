# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.mod "recaptcha"
  s.summary = "recaptcha support for decko"
  s.description = ""
  s.add_runtime_dependency "recaptcha", "~> 4.13.1"
end
