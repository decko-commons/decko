module Cardio
  class Mod
    class Loader
      # arguably overkill, the set pattern loader makes set patterns use
      # directory/file-aware loading much as set patterns do. Since they are so
      # rarely added, this optimization should probably be deprecated
      class SetPatternLoader < Loader
        def template_class
          SetPatternTemplate
        end

        def load_strategy_class strategy
          LoadStrategy.class_for_set_pattern strategy
        end

        def each_file &block
          each_mod_dir :set_pattern do |base_dir|
            each_file_in_dir base_dir, &block
          end
        end
      end

      # templates for set pattern modules
      class SetPatternTemplate < ModuleTemplate
        def to_const
          return Object if simple_load?

          Card::Set.const_get_or_set(@pattern.camelize) do
            Class.new(Card::Set::Pattern::Base)
          end
        end

        # correct line number for error messages
        def offset
          -5
        end

        private

        def auto_comment
          %(# Set Pattern: #{@pattern.camelize}\n#)
        end

        def module_chain
          "class Card::Set::#{@pattern.camelize} < Card::Set::Pattern::Base"
        end

        def preamble_bits
          [module_comment,
           module_chain,
           "cattr_accessor :options",
           "class << self"]
        end

        def postamble
          <<-RUBY
            end
            register "#{@pattern}".underscore.to_sym, (options || {})
          end
          RUBY
        end
      end
    end
  end
end
