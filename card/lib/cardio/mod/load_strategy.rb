module Cardio
  module Mod
    # Shared code for the three different load strategies: Eval, TmpFiles and BindingMagic
    class LoadStrategy
      class << self
        attr_accessor :tmp_files, :current

        def klass symbol
          case symbol
          when :tmp_files     then TmpFiles
          when :binding_magic then BindingMagic
          else                     Eval
          end
        end

        def tmp_files?
          Cardio.config.load_strategy == :tmp_files
        end
      end

      attr_reader :loader
      delegate :template_class, :each_file, to: :loader

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
