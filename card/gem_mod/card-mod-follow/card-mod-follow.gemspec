# -*- encoding : utf-8 -*-

require "../../../decko_gem"

DeckoGem.new do |s|
  s.mod "follow"
  s.depends_on_mod :carrierwave
  s.summary = "follower notifications"
  s.description = ""
end
