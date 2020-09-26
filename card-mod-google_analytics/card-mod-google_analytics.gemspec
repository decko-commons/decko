# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.mod "google_analytics"
  s.summary = "Google Analytics support for decko"
  s.description = ""
end
