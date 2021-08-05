module Cardio
  module Delaying
    def delaying! on=true
      config.delaying = (on == true)
    end

    def delaying?
      config.delaying
    end
  end
end
