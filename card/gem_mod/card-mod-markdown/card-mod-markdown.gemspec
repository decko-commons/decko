# -*- encoding : utf-8 -*-

require "../../../decko_gem"

Gem::Specification.new do |s|
  DeckoGem.shared s
  DeckoGem.mod s, "markdown"

  s.summary = "markdown support for decko"
  s.description = "use markdown in decko card content"
  s.add_runtime_dependency "kramdown"
end
