# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "markdown" do |s, d|
  s.required_ruby_version = ">= 3.0.0"
  s.summary = "markdown support for decko"
  s.description = "use markdown in decko card content"
  # d.depends_on_mod :ace_editor
  d.depends_on ["kramdown", "~> 2.4"],
               ["kramdown-syntax-coderay", "~> 1.0"]
end
