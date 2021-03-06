module Cardio
  class Mod
    class LoadStrategy
      # Put everything for the module definition in one string and the evaluate
      # it immediately with ruby's eval method.
      class Eval < LoadStrategy
        def load_modules
          each_file do |abs_path, module_names|
            template_class.new(module_names, abs_path, self).build
          end
        end
      end
    end
  end
end
