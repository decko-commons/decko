Rails.autoloaders.each do |autoloader|
  #autoloader.inflector = ModInflector.new
end

Rails.autoloaders.log!
