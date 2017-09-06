class Card
  module Mod
    module Loader
      class PatternLoader
        #
        class PatternModule < ModuleTemplate
          def to_const
            return Object if simple_load?
            Card::Set.const_get_or_set(@pattern.camelize) {Class.new(Card::Set::Pattern::Abstract)}
          end

          # correct line number for error messages
          def offset
            -3
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
              register "#{@pattern.underscore}", (options || {})
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
