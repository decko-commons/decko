Cardio.config.active_job.queue_adapter = :delayed_job

Before("@delayed-jobs") do
  Cardio.delaying!
end

After("@delayed-jobs") do
  Cardio.delaying! :off
end

Before("@background-jobs") do
  Cardio.delaying!
  system "env RAILS_ENV=cucumber rake jobs:work &"
end

After("@background-jobs") do
  Cardio.delaying! :off
  system "ps -ef | grep 'rake jobs:work' | grep -v grep | awk '{print $2}' | "\
         "xargs kill -9"
end
