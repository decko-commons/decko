require_relative "../module_loader"
require_relative "../module_template/set_module"

class Card
  module Mod
    module Loader
      class ModuleLoader
        # A SetLoader object loads all set modules for a list of mods.
        # The mods are given by a Mod::Dirs object.
        # SetLoader can use three different strategies to load the set modules.
        class SetLoader < ModuleLoader
          @module_type = :set
          @module_template_class = ModuleTemplate::SetModule

          def load_strategy_class load_strategy
            case load_strategy
            when :tmp_files
              LoadStrategy::SetTmpFiles
            when :binding_magic
              LoadStrategy::SetBindingMagic
            else
              LoadStrategy::Eval
            end
          end

          def load
            super
            Card::Set.process_base_modules
            Card::Set.clean_empty_modules
          end
        end
      end
    end
  end
end
