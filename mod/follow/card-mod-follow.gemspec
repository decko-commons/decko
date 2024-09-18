# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "follow" do |s, d|
  d.depends_on_mod :carrierwave
  d.required_ruby_version ">= 3.0.0"
  s.summary = "follower notifications"
  s.description = ""
end
