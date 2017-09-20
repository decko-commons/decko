class Card
  module Mod
    class Loader
      class SetPatternLoader < Loader
        @module_type = :set_pattern

        def load_strategy_class load_strategy
          case load_strategy
          when :tmp_files
            LoadStrategy::PatternTmpFiles
          else :eval
            LoadStrategy::Eval
          end
        end

        class Template < ModuleTemplate
          def to_const
            return Object if simple_load?
            Card::Set.const_get_or_set(@pattern.camelize) do
              Class.new(Card::Set::Pattern::Abstract)
            end
          end

          # correct line number for error messages
          def offset
            -6
          end

          private

          def module_chain
            klass = "Card::Set::#{@pattern.camelize}"
            "class #{klass} < Card::Set::Pattern::Abstract"
          end

          def preamble
            <<-RUBY
              cattr_accessor :options
              class << self
            RUBY
          end

          def postamble
            <<-RUBY
              end
              register "#{@pattern}".underscore.to_sym, (options || {})
            RUBY
          end

          def end_chain
            "end"
          end
        end

      end
    end
  end
end
