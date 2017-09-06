class Card
  module Mod
    module Loader
      class PatternLoader
        def initialize mod_dirs, load_strategy: :eval
          load_strategy_class =
            case load_strategy
            when :tmp_files     then Card::Mod::Loader::PatternLoader::TmpFiles
            when :binding_magic then BindingMagic
            else                     Card::Mod::LoadStrategy::Eval
            end
          @load_strategy = load_strategy_class.new mod_dirs, :set_pattern, PatternModule
        end

        def load
          @load_strategy.load_modules
        end
      end
    end
  end
end
