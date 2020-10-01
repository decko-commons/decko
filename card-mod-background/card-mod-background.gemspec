# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "background" do |s, _d|
  s.summary = "Background processing with Delayed Job"
  s.description = ""
  #   s.add_runtime_dependency "daemons"
  s.add_runtime_dependency "delayed_job_active_record", ">= 4.1"
  # s.add_runtime_dependency "delayed_job_web"
end
