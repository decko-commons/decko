
module Cardio
  class Railtie < Rails::Railtie
    # handles config and path defaults
    initializer "card.load_environment_config",
                before: :load_environment_config, group: :all do |app|
      app.config.paths["card/config/environments"].existent.each do |environment|
        require environment
      end
    end

    defaults_yml = File.expand_path "defaults.yml", __dir__
    YAML.load_file(defaults_yml).each_pair do |setting, value|
      config.send "#{setting}=", *value
    end

    config.i18n.enforce_available_locales = true
    config.read_only = !ENV["DECKO_READ_ONLY"].nil?
    config.load_strategy = (ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval)
  end
end
