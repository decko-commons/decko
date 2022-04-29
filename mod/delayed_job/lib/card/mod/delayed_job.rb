require "delayed_job_active_record"

Cardio::Railtie.config.tap do |config|
  config.delaying = false
  config.active_job.queue_adapter = :delayed_job
end
