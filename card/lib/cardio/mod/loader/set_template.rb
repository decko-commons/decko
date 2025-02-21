module Cardio
  class Mod
    class Loader
      # Template for set modules
      class SetTemplate < ModuleTemplate
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

        def processed_content
          add_explicit_format_modules if @strategy.clean_comments?
          super
        end

        def add_explicit_format_modules
          @content.gsub!(/^ *format +:?(\w+)? *do *$/) do
            format_name = Regexp.last_match(1)
            format_name = format_name.blank? ? nil : format_name.to_sym
            "module #{module_name format_name}; " \
            "module_parent.send :register_set_format, "\
            "#{format_class format_name}, self; "\
            "extend Card::Set::AbstractFormat"
          end
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
          -5
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

        def auto_comment
          "# Set: #{label_body(*@modules)}\n#"
        end

        def label_body *anchors
          if @pattern == "Abstract"
            "Abstract (#{@modules.join ', '})"
          else
            pattern_label(*anchors)
          end
        end

        def pattern_label *anchors
          anchor_count = pattern_class.anchor_parts_count
          label = pattern_class.label(pattern_anchor(*anchors, anchor_count))
          remainder = anchors[anchor_count..]
          label += " (#{remainder.join ', '})" if remainder.any?
          label
        end

        def pattern_anchor *anchors, anchor_count
          if anchor_count.zero?
            ""
          else
            anchors[0..anchor_count].join(Card::Name.joint)
          end
        end

        def pattern_class
          @pattern_class ||= Card::Set.const_get_or_set(@pattern.camelize) { Class.new }
        end

        def capture_last_module
          module_chain
          @last_module = @module_chain.pop
        end

        def set_extension
          "extend Card::Set" unless helper_module?
        end

        def location_method
          %(def self.source_location; "#{@content_path}"; end)
        end

        def postamble
          "end;" * (@modules.size + 3)
        end

        #   [set_registration, ends].compact.join "\n"
        # end
        #
        # def set_registration
        #   "Card::Set.register_set self" unless helper_module?
        # end
        #
        # def ends
        # end
      end
    end
  end
end
