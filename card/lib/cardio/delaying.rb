module Cardio
  # Convenient extendable API for turning delaying on and off.
  module Delaying
    def delaying! on=true
      Card.config.delaying = (on == true)
    end

    def delaying?
      Card.config.delaying
    end
  end
end
