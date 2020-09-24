# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "google_analytics"

  s.summary = "Google Analytics support for decko"
  s.description = ""
end
