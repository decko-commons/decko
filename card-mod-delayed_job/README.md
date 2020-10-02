Run card events after an act is completed using DelayedJobs.

Any card event defined in the `integrate_with_delay` stage will be handled after an act
is completed.

At present you will need to add the following configuration to application.rb or an
environments.rb file:
    
    config.active_job.queue_adapter = :delayed_job
    config.delaying = true

You will then need to run a separate DelayedJob process


You will need to add the following to routes.rb in order to have access to a
web interface to inspect the jobs:

    require 'decko/engine'
    require 'delayed_job_web'
    
    Rails.application.routes.draw do
     mount DelayedJobWeb => "/*admin/delayed_job"
     mount Decko::Engine => '/'
    end
