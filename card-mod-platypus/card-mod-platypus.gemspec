# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "platypus" do |s, _d|
  s.summary = "support for core developers (platypuses)"
  s.description = ""

  [
    ["decko-rspec"],
    ["decko-cucumber"],
    ["yard"],
    ["fog-aws"],

    ["codeclimate-test-reporter"],
    ["timecop"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
