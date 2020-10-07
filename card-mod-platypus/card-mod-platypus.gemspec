# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "platypus" do |s, _d|
  s.summary = "support for core developers (platypuses)"
  s.description = ""

  [
    ["codeclimate-test-reporter"],
    ["fog-aws"],
    ["yard"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
