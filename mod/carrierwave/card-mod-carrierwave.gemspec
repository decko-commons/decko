# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "carrierwave" do |s, d|
  s.summary = "File and Image handling"
  s.description = ""
  d.depends_on ["carrierwave", "~> 3.0"],
               ["mini_magick", "~> 4.12"],
               ["ssrf_filter", "~> 1.1"]

  d.depends_on_mod :history, :permissions
end
