Run card events after the action is completed.

You will need the following in config/application.rb (or in the desired environment 
files):

    config.active_job.queue_adapter = :delayed_job

And you will need at least the following in routes.rb

    require 'decko/engine'
    require 'delayed_job_web'
    
    Rails.application.routes.draw do
     mount DelayedJobWeb => "/*admin/delayed_job"
     mount Decko::Engine => '/'
    end
