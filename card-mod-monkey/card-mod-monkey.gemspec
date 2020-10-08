# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "monkey" do |s, d|
  s.summary = "dev support for mod developers (monkeys)"
  s.description = ""
  d.depends_on "colorize",
               # CODE GENERATION
               "html2haml",
               # CODE STYLE
               ["rubocop", "0.88"],      # 0.89 introduced bugs.
               # ["rubocop-decko"],
               # DEBUGGING
               "better_errors",
               "pry-rails",
               "pry-rescue",
               "pry-stack_explorer",
               "pry-byebug"
end
