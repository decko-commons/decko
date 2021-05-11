# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "machines" do |s, d|
  s.summary = "decko machines"
  s.description = ""
  s.add_dependency "execjs", "~>2.7", "!=2.8.0" # 2.8.0 broke machine_spec
  d.depends_on_mod :virtual, :format, :list, :carrierwave
end
