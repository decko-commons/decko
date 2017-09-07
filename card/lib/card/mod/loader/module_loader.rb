class Card
  module Mod
    module Loader
      # A SetLoader object loads all set modules for a list mods.
      # The mods are given by a Mod::Dirs object.
      # SetLoader can use three different strategies to load the set modules.
      #
      # The former w
      class ModuleLoader
        class << self
          attr_reader :module_type, :module_template_class
        end

        def initialize mod_dirs, load_strategy: :eval
          @load_strategy = load_strategy_class(load_strategy).new(
              mod_dirs, self.class.module_type, self.class.module_template_class
          )
        end

        def load_strategy_class load_strategy
          case load_strategy
          when :tmp_files     then LoadStrategy::TmpFiles
          when :binding_magic then LoadStrategy::BindingMagic
          else                     LoadStrategy::Eval
          end
        end

        def load
          @load_strategy.load_modules
        end
      end
    end
  end
end
