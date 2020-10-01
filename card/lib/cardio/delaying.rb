module Cardio
  module Delaying
    def delaying! on=true
      Cardio.config.delaying = (on == true)
    end

    def delaying?
      Cardio.config.delaying
    end
  end
end
