# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "monkey" do |s, d|
  s.summary = "dev support for mod developers (monkeys)"
  s.description = ""
  d.depends_on ["colorize",             "~> 0.8"],
               # CODE GENERATION
               ["html2haml",            "~> 2.2"],
               # CODE STYLE
               ["rubocop",             "~> 1.17"],
               # ["rubocop-decko"],
               # DEBUGGING
               ["better_errors",        "~> 2.9"],
               ["pry-rails",            "~> 0.3"],
               ["pry-rescue",           "~> 1.5"],
               ["pry-stack_explorer",   "~> 0.6"],
               ["pry-byebug",           "~> 3.9"]
end
