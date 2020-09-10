class Card
  module Mod
    # ModuleTemplate is an abstract class to build ruby modules out of
    # deckos dsl for sets and set patterns.
    # {Loader::SetLoader::Template} and {Loader::SetPatternLoader::Template} inherit
    # from it and adapt the template to their needs.
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
        simple_load? ? @content : processed_content
      end

      def processed_content
        capture_module_comment if @strategy.clean_comments?
        module_content
      end

      # Just run the code of the source.
      # Don't use the path to the file as module hierarchy.
      def simple_load?
        @content =~ /\A#!\s?simple load/
      end

      private

      # find all comment lines at the beginning of a mod file, up to the first
      # non-comment line.  (These will be inserted before the module declaration,
      # so that Yard will interpret them as a module comment.)
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
        line.match?(/^ *\#/)
      end

      # loader template must implement #preamble_bits
      def preamble
        preamble_bits.join "\n"
      end

      def module_comment
        return "" unless @strategy.clean_comments?
        @module_comment = nil if @module_comment.blank?
        [auto_comment, @module_comment].compact.join "\n"
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
