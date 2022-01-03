Cardio.config.tap do |cc|
  Delayed::Worker.tap do |dw|
    dw.delay_jobs = cc.delaying
    dw.max_attempts = 1
    dw.destroy_failed_jobs = false
  end
end

Cardio.extend Cardio::DelayedJob
