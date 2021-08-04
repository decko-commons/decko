module Cardio
  # override default methods to handle DelayedJob needs
  module DelayedJob
    def delaying! on=true
      super
      Delayed::Worker.delay_jobs = Cardio.config.delaying
    end
  end

  # Convenient API for turning delaying on and off.
  module Delaying
    def delaying! on=true
      Cardio.config.delaying = (on == true)
    end

    def delaying?
      Cardio.config.delaying
    end
  end
end

Cardio.extend Cardio::Delaying
