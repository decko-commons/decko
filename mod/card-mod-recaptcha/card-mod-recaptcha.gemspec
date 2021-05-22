# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "recaptcha" do |s, d|
  s.summary = "recaptcha support for decko"
  s.description = ""
  d.depends_on ["recaptcha", "~> 4.13.1"]
end
