class Card
  module Mod
    class LoadStrategy
      class Eval < Card::Mod::LoadStrategy
        def load_modules
          each_file do |abs_path, module_names|
            template = @module_template.new module_names, abs_path
            template.build
          end
        end
      end
    end
  end
end
