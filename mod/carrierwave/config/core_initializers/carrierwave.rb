require "carrierwave"

ActiveSupport.on_load :card do
  Card.extend CarrierWave::Mount
end
