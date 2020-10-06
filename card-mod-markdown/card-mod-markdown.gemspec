# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "markdown" do |s, _d|
  s.summary = "markdown support for decko"
  s.description = "use markdown in decko card content"
  s.add_runtime_dependency "kramdown"
end
