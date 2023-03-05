# -*- encoding : utf-8 -*-

require "rails/generators"
require "rails/generators/active_record"
require "colorize"

module Cardio
  # for now, this just fulfills zeitwerk expectations. File is here for require calls.
  module Generators
    # methods shared across Generator bases (which inherit from Rails generator classes)
    module ClassMethods
      def source_root path=nil
        if path
          @_card_source_root = path
        else
          @_card_source_root ||= File.expand_path(
            "../../generators/#{generator_name}/templates", __FILE__
          )
        end
      end

      # Override Rails default banner (using card/decko for the command name).
      def banner
        usage_args = arguments.map(&:usage).join " "
        text = "\n#{banner_command} generate #{namespace} #{usage_args} [options]".green
        text.gsub(/\s+/, " ")
      end

      def banner_command
        Command.bin_name
      end

      # Override Rails namespace handling so we can put generators in `module Cardio`
      def namespace name=nil
        return super if name
        @namespace ||= super.sub(/cardio:/, "")
      end
    end
    delegate :banner_command, to: :class
  end
end

module Rails
  # override to hide all the rails generators that don't apply in a card/decko context
  module Generators
    class << self
      # TODO: autogenerate
      def generator_names
        %i[mod set migration]
      end

      def help command="generate"
        caller = Cardio::Command.bin_name
        puts "Usage:"
        puts "  #{caller} #{command} GENERATOR [args] [options]".green
        puts
        puts "General options:"
        puts "  -h, [--help]     # Print generator's options and usage"
        puts "  -p, [--pretend]  # Run but do not make any changes"
        puts "  -f, [--force]    # Overwrite files that already exist"
        puts "  -s, [--skip]     # Skip files that already exist"
        puts "  -q, [--quiet]    # Suppress status output"
        puts
        puts "Please choose a generator below."
        puts
        generator_names.each do |name|
          puts "  #{name}".light_cyan
        end
        puts
      end
    end
  end
end
