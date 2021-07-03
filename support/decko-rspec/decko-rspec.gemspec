# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.gem "decko-rspec" do |s, d|
  s.summary = "rspec support for decko monkeys"
  s.description = ""
  d.depends_on ["i18n-tasks",               ">= 0.9.5"],
               ["minitest",                ">= 5.14.4"],
               ["nokogumbo",                ">= 2.0.5"],
               ["rails-controller-testing", ">= 1.0.4"],
               ["rr",                       ">= 3.0.5"],
               ["rspec-html-matchers",      ">= 0.9.4"],
               ["rspec",                     ">= 3.10"],
               ["rspec-rails",                  ">= 5"],
               ["rubocop-rspec",              ">= 2.4"],
               ["simplecov",                 ">= 0.21"],
               ["spork",                      ">= 0.9"],
               ["timecop",                  ">= 0.9.4"]
  # following might be needed to get Jasmine going again?
  # ["phantomjs", "1.9.7.1"], # locked because 1.9.8.0 is breaking
  #  "sprockets",              # just so above works
end
