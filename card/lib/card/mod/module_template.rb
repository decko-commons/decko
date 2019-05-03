class Card
  module Mod
    # ModuleTemplate is an abstract class to build ruby modules out of
    # deckos dsl for sets and set patterns.
    # {SetLoader::Template} and {SetPatternLoader::Template} inherit from it and
    # adapt the template to their needs.
    class ModuleTemplate
      def initialize modules, content_path, strategy
        modules = Array.wrap modules
        @pattern = modules.shift
        @modules = modules
        @content = ::File.read content_path
        @content_path = content_path
        @strategy = strategy
      end

      # Evaluates the module in the top level namespace.
      def build
        eval to_s, TOPLEVEL_BINDING, @content_path, offset
      end

      # @return [String] the ruby code to build the modal
      def to_s
        if simple_load?
          @content
        else
          processed_content
        end
      end

      def processed_content
        module_content
      end

      # Just run the code of the source.
      # Don't use the path to the file as module hierarchy.
      def simple_load?
        @content =~ /\A#!\s?simple load/
      end

      private

      def preamble
        preamble_bits.join "\n"
      end

      def module_content
        # for unknown reasons strip_heredoc doesn't work properly
        # and with trailing whitespace code like `=begin` fails
        <<~RUBY.strip_heredoc
          # -*- encoding : utf-8 -*-
          #{preamble}
          #{@content}
          #{postamble}
          # ~~ generated from #{@content_path} ~~
        RUBY
      end
    end
  end
end
