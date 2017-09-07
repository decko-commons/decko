class Card
  module Mod
    module Loader
      class ModuleTemplate
        # Generates the code for a set module.
        class SetModule < ModuleTemplate
          def initialize modules, content_path
            super
            @modules.pop if helper_module?
          end

          def to_const
            return Object if simple_load?
            pattern_klass = Card::Set.const_get_or_set(@pattern.camelize) { Class.new }

            @modules.inject(pattern_klass) do |const, name_part|
              const.const_get_or_set name_part do
                Module.new
              end
            end
          end

          def helper_module?
            if @is_helper_module.nil?
              @is_helper_module = @content =~ /\A#!\s?not? set module/
            else
              @is_helper_module
            end
          end

          # correct line number for error messages
          def offset
            # One line for the module chain and one line for the source_location method
            # The template changes so rarely that doesn't seem worth it to count
            # it during runtime
            helper_module? ? -3 : -2
          end

          private

          def submodule_chain
            @modules.map { |m| "module #{m};" }.join " "
          end

          def module_chain
            "class Card; module Set; class #{@pattern.camelize}; #{submodule_chain}"
          end

          def preamble
            <<-RUBY.strip_heredoc
              #{"extend Card::Set" unless helper_module?}
              def source_location; "#{@content_path}"; end
            RUBY
          end

          def end_chain
            "end;" * (@modules.size + 3)
          end
        end
      end
    end
  end
end
