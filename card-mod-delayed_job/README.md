<!--
# @title README - mod: delayed job
-->

This mod lets you run card events after sending an act response by using DelayedJobs.

Any card event defined in the `integrate_with_delay` stage will be handled after an act
is completed. For example, suppose you define a `notify` event in `integrate_with_delay`
that's intended to notify you when someone edits a card. With this mod, the email will
be sent _after_ the card is edited and the editor has received his web response.

At present you will need to add the following configuration to application.rb or an
environments.rb file:
    
    config.active_job.queue_adapter = :delayed_job
    config.delaying = true

You will then need to run a separate background process to process these events, eg:

     script/delayed_job start

See https://github.com/collectiveidea/delayed_job#running-jobs for more info.


To have access to a web interface to inspect the jobs, add something like this
to `config/routes.rb`:

    require 'decko/engine'
    require 'delayed_job_web'
    
    Rails.application.routes.draw do
     mount DelayedJobWeb => "/*admin/delayed_job"
     mount Decko::Engine => '/'
    end

...and then it will show up at `/*admin/delayed_job`.