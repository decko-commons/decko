Bundler.require :default, *Rails.groups

module Cardio
  class Application < Rails::Application
    initializer "cardio.load_default_config",
                before: :load_environment_config, group: :all do
      default_autoload_paths

      default_configs.each_pair do |setting, value|
        config.send "#{setting}=", *value
      end
    end

    private

    # TODO: many of these defaults should be in mods!
    def default_configs
      defaults_from_yaml.merge(
        read_only: !ENV["DECKO_READ_ONLY"].nil?,
        load_strategy: (ENV["REPO_TMPSETS"] || ENV["TMPSETS"] ? :tmp_files : :eval)
      )
    end

    def defaults_from_yaml
      filename = File.expand_path "defaults.yml", __dir__
      YAML.load_file filename
    end

    def default_autoload_paths
      config.autoload_paths += Dir["#{Cardio.gem_root}/lib"]

      # TODO: this should use each_mod_path, but it's not available when this is run
      # This means libs will not get autoloaded (and sets not watched) if the mod
      # dir location is overridden in config
      [Cardio.gem_root, config.root].each do |dir|
        autoload_and_watch "#{dir}/mod/*"
      end
      Cardio.gem_mod_specs.each_value do |spec|
        autoload_and_watch spec.full_gem_path
      end

      # the watchable_dirs are processes in
      # set_clear_dependencies_hook hook in the railties gem in finisher.rb

      # TODO: move this to the right place in decko
      config.autoload_paths += Dir["#{Decko.gem_root}/lib"]
    end

    def autoload_and_watch mod_path
      config.autoload_paths += Dir["#{mod_path}/lib"]
      config.watchable_dirs["#{mod_path}/set"] = [:rb]
    end
  end
end
