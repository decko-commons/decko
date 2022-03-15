require "delayed_job_active_record"
require "delayed_job_web"

Cardio.config.tap do |cc|
  Delayed::Worker.tap do |dw|
    dw.delay_jobs = cc.delaying
    dw.max_attempts = 1
    dw.destroy_failed_jobs = false
  end
end

Cardio.extend Cardio::DelayedJob

DelayedJobWeb.use Rack::Auth::Basic do |email, password|
  account = Card::Auth.authenticate email, password
  Card::Auth.admin? account&.left_id
end
