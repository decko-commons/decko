Card.config.active_job.queue_adapter = :delayed_job

Before("@delayed-jobs") do
  Cardio.config.delaying = true
end

After("@delayed-jobs") do
  Cardio.config.delaying = false
end

Before("@background-jobs") do
  Cardio.config.delaying = true
  system "env RAILS_ENV=cucumber rake jobs:work &"
end

After("@background-jobs") do
  Cardio.config.delaying = false
  system "ps -ef | grep 'rake jobs:work' | grep -v grep | awk '{print $2}' | "\
         "xargs kill -9"
end
