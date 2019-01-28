class Card
  module Mod
    # Tries to build the module with as little string evaluation as possible.
    # The problem here is that in methods like `module_eval` the Module.nesting
    # list gets lost so all references in mod files to constants in the
    # Card::Set namespace don't work.
    # The solution is to construct a binding with the right Module.nesting list.
    class BindingMagic < LoadStrategy
      def load_modules
        each_file do |abs_path, const_parts|
          sm = SetModule.new const_parts, abs_path

          set_module = sm.to_const
          set_module.extend Card::Set unless sm.helper_module?
          set_module.module_eval do
            def self.source_location
              abs_path
            end
          end

          # Since module_eval doesn't take a binding argument, we have to
          # execute module_eval with eval.
          eval "#{set_module}.module_eval ::File.read('#{abs_path}'), '#{abs_path}'",
               module_path_binding(set_module)
        end
      end

      # Get a binding with a Module.nesting list that contains the
      # given module and all of its containing modules as described
      # by its fully qualified name in inner-to-outer order.
      def module_path_binding mod
        if mod.name.to_s.empty?
          raise ArgumentError,
                "Can't determine path nesting for a module with a blank name"
        end

        m = nil
        b = TOPLEVEL_BINDING
        mod.name.split("::").each do |part|
          m, b =
            eval(
              "[ #{part} , #{part}.module_eval('binding') ]",
              b
            )
        end
        raise "Module found at name path not same as specified module" unless m == mod

        b
      end
    end
  end
end
