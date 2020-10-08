# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "platypus" do |s, d|
  s.summary = "support for core developers (platypuses)"
  s.description = ""
  d.depends_on "codeclimate-test-reporter", "fog-aws", "yard"
end
