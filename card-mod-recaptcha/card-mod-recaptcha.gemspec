# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "recaptcha" do |s, _d|
  s.summary = "recaptcha support for decko"
  s.description = ""
  s.add_runtime_dependency "recaptcha", "~> 4.13.1"
end
