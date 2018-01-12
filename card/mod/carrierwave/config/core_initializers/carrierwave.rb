ActiveSupport.on_load :before_card do
  require "carrierwave"
end

ActiveSupport.on_load :card do
  Card.extend CarrierWave::Mount
end
