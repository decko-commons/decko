# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "spring" do |s, _d|
  s.summary = "spring integration for decko development"
  s.description = "Spring speeds up development by keeping your application running " \
                  "in the background. Read more: https://github.com/rails/spring"

  [
    ["listen", "3.0.6"],
    ["spring"],
    ["spring-commands-rspec"],
    ["spring-commands-cucumber"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
