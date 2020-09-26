# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.new do |s|
  s.mod "monkey_development"
  s.summary = "dev support for monkey developers (monkeys)"
  s.description = ""
  [
    ["colorize"],
    ["delayed_job_active_record", "~> 4.1"],
    ["html2haml"],
    ["sprockets"], # just so above works
    ["phantomjs", "1.9.7.1"], #locked because 1.9.8.0 is breaking
    ["better_errors"],
    ["binding_of_caller"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
