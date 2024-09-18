# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.gem "decko-spring" do |s, d|
  s.required_ruby_version ">= 3.0.0"
  s.summary = "spring integration for decko development"
  s.description = "Spring speeds up development by keeping your application running " \
                  "in the background. Read more: https://github.com/rails/spring"
  d.depends_on ["listen",                   "~> 3.8"],
               ["spring",                   "~> 4"],
               ["spring-commands-rspec",    "~> 1.0"],
               ["spring-commands-cucumber", "~> 1.0"]
end
