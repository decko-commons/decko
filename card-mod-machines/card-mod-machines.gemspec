# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "machines" do |s, d|
  s.summary = "decko machines"
  s.description = ""
  d.depends_on_mod :virtual, :format, :list, :carrierwave
end
