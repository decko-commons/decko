module Cardio
  # easy access method for delay configuration
  module Delaying
    def delaying! on=true
      config.delaying = (on == true)
    end

    def delaying?
      config.delaying
    end
  end
end
