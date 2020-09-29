# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "platypus" do |s, _d|
  s.summary = "support for core developers (platypuses)"
  s.description = ""

  [
    ["decko-rspec"],
    ["decko-cucumber"],
    ["fog-aws"],

    ["simplecov", "~> 0.7.1"], # test coverage
    ["codeclimate-test-reporter"],

    ["timecop", "=0.3.5"], # not clear on use/need.
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
