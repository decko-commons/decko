# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "delayed_job" do |s, d|
  s.required_ruby_version = ">= 3.0.0"
  s.summary = "Background processing with Delayed Job"
  s.description = ""
  d.depends_on ["daemons",                   "~> 1.4"],
               ["delayed_job_active_record", "~> 4.1"],
               ["delayed_job_web",           "~> 1.4"]
end
