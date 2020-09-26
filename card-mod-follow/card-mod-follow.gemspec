# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.mod "follow"
  s.depends_on_mod :carrierwave
  s.summary = "follower notifications"
  s.description = ""
end
