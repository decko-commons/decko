# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.new do |s, d|
  d.mod "markdown"
  s.summary = "markdown support for decko"
  s.description = "use markdown in decko card content"
  s.add_runtime_dependency "kramdown"
end
