# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.mod "markdown"
  s.summary = "markdown support for decko"
  s.description = "use markdown in decko card content"
  s.add_runtime_dependency "kramdown"
end
