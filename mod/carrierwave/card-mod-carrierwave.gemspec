# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "carrierwave" do |s, d|
  s.summary = "File and Image handling"
  s.description = ""
  d.depends_on ["carrierwave", "~> 2.2"],
               ["mini_magick", "~> 4.2"],
               ["ssrf_filter", "~> 1.0.7"]
  # Note: ssrf_filter version 1.1.x causing problems with http responses with nil sockets

  d.depends_on_mod :history, :permissions
end
