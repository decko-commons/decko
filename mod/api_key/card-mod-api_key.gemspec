# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "api_key" do |s, d|
  s.summary = "API Keys and JWT Tokens for Decko"
  s.description = ""
  d.depends_on_mod :account
end
