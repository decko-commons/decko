# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "markdown" do |s, d|
  s.summary = "markdown support for decko"
  s.description = "use markdown in decko card content"
  d.depends_on "kramdown"
end
