module Cardio
  class Mod
    # The main way to enhance cards' appearance and behavior is through the card set DSL.
    #
    # The default mechanism for loading DSL code is live evaluation, or Eval. Eval is
    # fast and efficient and preferred for a wide range of scenarios, including
    # production and live debugging. But Eval is problematic for generating both test
    # coverage reports with Simplecov and documentation sites with YARD.
    #
    # For those two reasons, we make it possible to load the DSL code by generating
    # fully explicit ruby modules in tmp files.
    #
    # Shared code for the three different load strategies: Eval, TmpFiles and BindingMagic
    class LoadStrategy
      class << self
        attr_accessor :tmp_files, :current

        def class_for_set strategy
          case strategy
          when :tmp_files then SetTmpFiles
          when :binding_magic then SetBindingMagic
          else Eval
          end
        end

        def class_for_set_pattern strategy
          strategy == :tmp_files ? PatternTmpFiles : Eval
        end

        def tmp_files?
          Cardio.config.load_strategy == :tmp_files
        end
      end

      attr_reader :loader
      delegate :template_class, :pattern_groups, :each_file, :mod_dirs, :parts_from_path,
               to: :loader

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
