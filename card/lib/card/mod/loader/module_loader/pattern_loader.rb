require_relative "../module_loader"
require_relative "../module_template/pattern_module"

class Card
  module Mod
    module Loader
      class ModuleLoader
        class PatternLoader < Loader::ModuleLoader
          @module_type = :set_pattern
          @module_template_class = ModuleTemplate::PatternModule

          def load_strategy_class load_strategy
            case load_strategy
            when :tmp_files
              LoadStrategy::PatternTmpFiles
            else :eval
              LoadStrategy::Eval
            end
          end
        end
      end
    end
  end
end
