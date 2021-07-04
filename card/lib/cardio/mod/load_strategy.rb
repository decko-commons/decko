module Cardio
  class Mod
    # Shared code for the three different load strategies: Eval, TmpFiles and BindingMagic
    class LoadStrategy
      class << self
        attr_accessor :tmp_files, :current

        def class_for_set strategy
          case strategy
          when :tmp_files     then SetTmpFiles
          when :binding_magic then SetBindingMagic
          else                     Eval
          end
        end

        def class_for_set_pattern strategy
          return PatternTmpFiles if strategy == :tmp_files

          Eval
        end

        def tmp_files?
          Cardio.config.load_strategy == :tmp_files
        end
      end

      attr_reader :loader
      delegate :template_class, :each_file, :mod_dirs, :parts_from_path, to: :loader

      def initialize loader
        LoadStrategy.current = self.class
        @loader = loader
      end

      def clean_comments?
        false
      end
    end
  end
end
