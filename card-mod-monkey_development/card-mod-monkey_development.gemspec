# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "monkey_development" do |s, _d|
  s.summary = "dev support for monkey developers (monkeys)"
  s.description = ""
  [
    ["colorize"],
    ["delayed_job_active_record", "~> 4.1"],
    ["html2haml"],
    ["sprockets"], # just so above works
    ["phantomjs", "1.9.7.1"], # locked because 1.9.8.0 is breaking
    ["better_errors"],
    ["binding_of_caller"],
    ["pry-rails"],
    ["pry-rescue"],
    ["pry-stack_explorer"],
    ["pry-byebug"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
