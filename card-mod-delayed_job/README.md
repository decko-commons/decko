Run card events after the action is completed using DelayedJobs

You will need to add the following to routes.rb in order to have access to a
web interface to inspect the jobs:

    require 'decko/engine'
    require 'delayed_job_web'
    
    Rails.application.routes.draw do
     mount DelayedJobWeb => "/*admin/delayed_job"
     mount Decko::Engine => '/'
    end
