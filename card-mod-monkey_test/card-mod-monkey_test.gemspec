# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "monkey_test" do |s, _d|
  s.summary = "testing support for mod developers (monkeys)"
  s.description = ""

  [
    ["card-mod-monkey_development"],
    ["capybara-puma"],
    ["rspec"],
    ["rspec-rails", "~>4.0.0.beta2"],   # behavior-driven-development suite
    ["spork", ">=0.9"],
    ["rubocop", "0.88"], # 0.89 introduced bugs. may get resolved in rubocop-decko update?
    # ["rubocop-decko"],
    ["nokogumbo"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
