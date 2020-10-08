class Cardio
  # Convenient extendable API for turning delaying on and off.
  module Delaying
    def delaying! on=true
      Cardio.config.delaying = (on == true)
    end

    def delaying?
      Cardio.config.delaying
    end
  end
end
