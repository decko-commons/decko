# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "list" do |s, d|
  s.summary = "list of cards"
  s.description = ""
  d.depends_on_mod :format, :collection
end
