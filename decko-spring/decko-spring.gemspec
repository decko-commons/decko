# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-spring" do |s, d|
  s.summary = "spring integration for decko development"
  s.description = "Spring speeds up development by keeping your application running " \
                  "in the background. Read more: https://github.com/rails/spring"
  d.depends_on ["listen", "3.0.6"],
               "spring", "spring-commands-rspec", "spring-commands-cucumber"
end
