if File.exist? "config/deck.yml"
  Decko.application.config.x = OpenStruct.new(Decko.application.config_for(:deck))
end
