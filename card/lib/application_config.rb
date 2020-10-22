module ApplicationConfig

  APPLICATION = File.join("config", "application.rb")

  def self.find_app_config path=Pathname.new(Dir.pwd)
    return if path.root?
    app_path = File.join(path, APPLICATION)
    return app_path if File.exist?(app_path)
    find_app_config(path.parent)
  end
end

