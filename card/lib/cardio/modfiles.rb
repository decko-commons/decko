module Cardio
  # methods for handling simple and gem mod paths/files
  module Modfiles
    # @return [Hash] in the form{ modname(String) => Gem::Specification }
    def gem_mod_specs
      Bundler.definition.specs.each_with_object({}) do |gem_spec, h|
        h[gem_spec.name] = gem_spec if gem_mod_spec? gem_spec
      end
    end

    # @return [True/False]
    def gem_mod_spec? spec
      return unless spec

      spec.name.match?(/^card-mod-/) || spec.metadata["card-mod"].present?
    end

    def each_mod_path &block
      each_simple_mod_path(&block)
      each_gem_mod_path(&block)
    end

    def each_simple_mod_path
      paths["mod"].each do |mods_path|
        Dir.glob("#{mods_path}/*").each do |single_mod_path|
          yield single_mod_path
        end
      end
    end

    def each_gem_mod_path
      gem_mod_specs.each_value do |spec|
        yield spec.full_gem_path
      end
    end

    def mod_migration_paths dir
      [].tap do |list|
        Cardio::Mod.dirs.each("db/#{dir}") { |path| list.concat Dir.glob path }
      end
    end
  end
end
