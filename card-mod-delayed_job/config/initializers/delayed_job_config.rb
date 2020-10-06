return unless Cardio.config.active_job.queue_adapter == :delayed_job

Cardio.config.tap do |cc|
  cc.delaying = true unless cc.delaying == false

  Delayed::Worker.tap do |dw|
    dw.delay_jobs = cc.delaying
    dw.max_attempts = 1
    dw.destroy_failed_jobs = false
  end
end

Cardio.extend Cardio::DelayedJob
