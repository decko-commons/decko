Rails.autoloaders.each do |autoloader|
  binding.pry
  autoloader.inflector = ModInflector.new
end