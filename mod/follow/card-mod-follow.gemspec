# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "follow" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  d.depends_on_mod :carrierwave
  s.summary = "follower notifications"
  s.description = ""
end
