# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.new do |s, d|
  d.mod "follow"
  d.depends_on_mod :carrierwave
  s.summary = "follower notifications"
  s.description = ""
end
