class Card
  module Mod
    class Loader
      # A SetLoader object loads all set modules for a list of mods.
      # The mods are given by a Mod::Dirs object.
      # SetLoader can use three different strategies to load the set modules.
      class SetLoader < Loader
        @module_type = :set

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
          Card::Set.process_base_modules
          Card::Set.clean_empty_modules
        end

        class Template < ModuleTemplate
          def initialize modules, content_path, strategy
            super
            @modules.pop if helper_module?
          end

          def to_const
            return Object if simple_load?

            @modules.inject(pattern_class) do |const, name_part|
              const.const_get_or_set name_part do
                Module.new
              end
            end
          end

          def pattern_class
            @pattern_class ||= Card::Set.const_get_or_set(@pattern.camelize) { Class.new }
          end

          def processed_content
            if @strategy.clean_comments?
              capture_module_comment
              add_explicit_format_modules
            end
            super
          end

          def add_explicit_format_modules
            @content.gsub!(/^ *format +:?(\w+)? *do *$/) do
              format_name = $1.blank? ? nil : $1.to_sym
              "module #{module_name format_name}; " \
              "parent.send :register_set_format, #{format_class format_name}, self; "\
              "extend Card::Set::AbstractFormat"
            end
          end

          def capture_module_comment
            content_lines = @content.split "\n"
            comment_lines = []

            content_lines.each do |line|
              comment?(line) ? comment_lines << content_lines.shift : break
            end

            @content = content_lines.join "\n"
            @module_comment = comment_lines.join "\n"
          end

          def comment? line
            line.match? /^ *\#/
          end

          def module_name format_name
            Card::Format.format_class_name format_name
          end

          def format_class format_name
            klass = ["Card::Format"]
            klass << module_name(format_name) if format_name
            klass.join "::"
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
            -6
          end

          private

          def submodule_chain
            @modules.map { |m| "module #{m};" }
          end

          def module_chain
            @module_chain ||=
              ["class Card", "module Set", "class #{@pattern.camelize}"] + submodule_chain
          end

          def preamble_bits
            capture_last_module
            [module_chain.join("; "),
             module_comment,
             @last_module,
             set_extension,
             location_method].compact
          end

          def module_comment
            @module_comment = nil if @module_comment.blank?
            [set_label, @module_comment].compact.join "\n"
          end

          def set_label
            "# Set: " + if @pattern == "Abstract"
                          "Abstract (#{@modules.join ', '})"
                        else
                          generate_set_label
                        end
          end

          def generate_set_label
            max_arg_index = pattern_class.method(:label).arity - 1
            pattern_class.label(*@modules[0..max_arg_index])
          end

          def capture_last_module
            module_chain
            @last_module = @module_chain.pop
          end

          def set_extension
            'extend Card::Set' unless helper_module?
          end

          def location_method
            %(def self.source_location; "#{@content_path}"; end)
          end

          def postamble
            "end;" * (@modules.size + 3)
          end
        end
      end
    end
  end
end
