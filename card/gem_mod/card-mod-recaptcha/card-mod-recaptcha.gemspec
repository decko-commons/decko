# -*- encoding : utf-8 -*-

require "../../../decko_gem"

DeckoGem.new do |s|
  s.mod "recaptcha"
  s.summary = "recaptcha support for decko"
  s.description = ""
  s.add_runtime_dependency "recaptcha", "~> 4.13.1"
end
