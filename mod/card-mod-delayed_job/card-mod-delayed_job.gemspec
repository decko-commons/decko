# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "delayed_job" do |s, d|
  s.summary = "Background processing with Delayed Job"
  s.description = ""
  d.depends_on "daemons",
               ["delayed_job_active_record", ">= 4.1"],
               "delayed_job_web"
end
