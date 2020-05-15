class Card
  module Mod
    class Loader
      class SetPatternLoader < Loader
        @module_type = :set_pattern

        def load_strategy_class load_strategy
          case load_strategy
          when :tmp_files
            LoadStrategy::PatternTmpFiles
          else # :eval
            LoadStrategy::Eval
          end
        end

        class Template < ModuleTemplate
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
             "extend Card::Set::Pattern::Helper",
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
end
