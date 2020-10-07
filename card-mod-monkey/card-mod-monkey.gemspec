# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "monkey" do |s, d|
  s.summary = "dev support for mod developers (monkeys)"
  s.description = ""
  d.depends_on "colorize",
               ["better_errors", "!= 2.8.2"],
               "html2haml",
               ["phantomjs", "1.9.7.1"], # locked because 1.9.8.0 is breaking
               "sprockets",              # just so above works

               ["rubocop", "0.88"],      # 0.89 introduced bugs.
               # ["rubocop-decko"],

               "pry-rails",
               "pry-rescue",
               "pry-stack_explorer",
               "pry-byebug"
end
