module Cardio
  module Mod
    class Loader
      # A SetLoader object loads all set modules for a list of mods.
      # The mods are given by a Mod::Dirs object.
      # SetLoader can use three different strategies to load the set modules.
      class SetLoader < Loader
        def template_class
          SetTemplate
        end

        def initialize args={}
          @no_all = args.delete :no_all
          super
        end

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
          # Card::Set.process_base_modules
          Card::Set.clean_empty_modules
        end

        # does not include abstract
        def main_patterns
          method = @no_all ? :nonbase_codes : :codes
          Card::Set::Pattern.send method
        end

        def each_file &block
          # each_file_with_patterns :abstract, &block
          each_file_with_patterns *main_patterns, &block
        end

        def each_file_with_patterns *patterns, &block
          each_mod_dir :set do |base_dir|
            patterns.each do |pattern|
              each_file_in_dir base_dir, pattern.to_s, &block
            end
          end
        end
      end
    end
  end
end
