# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.gem "decko-rspec" do |s, d|
  s.summary = "rspec support for decko monkeys"
  s.description = ""
  d.depends_on ["i18n-tasks",               "~> 0.9"],
               ["minitest",                "~> 5.14"],
               # ["nokogumbo",                "~> 2.0"],
               ["rails-controller-testing", "~> 1.0"],
               ["rr",                       "~> 3.0"],
               ["rspec-html-matchers",      "~> 0.10"],
               ["rspec",                   "~> 3.13"],
               ["rspec-rails",              "~> 7.0"],
               ["rubocop-rspec",            "~> 3.0"],
               ["simplecov",               "~> 0.21"],
               ["spork",                    "~> 0.9"],
               ["timecop",                  "~> 0.9"],
               ["capybara",                "~> 3.40"],
               ["rspec_junit_formatter",    "~> 0.4"]
  # following might be needed to get Jasmine going again?
  # ["phantomjs", "1.9.7.1"], # locked because 1.9.8.0 is breaking
  #  "sprockets",              # just so above works
end
