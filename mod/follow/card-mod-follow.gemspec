# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "follow" do |s, d|
  d.depends_on_mod :carrierwave
  s.summary = "follower notifications"
  s.description = ""
end
