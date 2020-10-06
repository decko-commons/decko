# -*- encoding : utf-8 -*-
require "optparse"
require 'cardio/commands/command/parser'

module Cardio
  module Commands
    class RspecCommand < Command
      class Parser < Command::Parser
        RSPEC_PATH_MESSAGE = <<-EOT

            {cmdname.upcase} ARGS

            You don't have to give a full path for FILENAME; the basename is enough.
            If FILENAME does not include '_spec', then rspec searches for the
            corresponding spec file.
            The line number always refers to the example in the spec file.

        EOT

        RSPEC_USAGE_MESSAGE = <<-EOT
            card rspec
             -d --deck-spec FILENAME(:LINE)  # Run spec for a Decko spec
             -c --core-spec FILENAME(:LINE)  # Run spec for a Card core spec
             -m --mod MODNAME                # Run all specs for a mod 
             -s --[no-]simplecov             # Run with simplecov
                --rescue                     # Run with pry-rescue
                --[no]-spring                # Run with spring
        EOT

        def define_options parser
          super # define common options from parent class
          cmdname = $0
          cmdname = $1 if cmdname =~ /\/([^\/]+)$/
          parser.banner = "Usage: #{cmdname} rspec [#{cmdname.upcase} ARGS] -- [RSPEC ARGS]\n\n" \
                            "RSPEC ARGS"
          parser.separator RSPEC_USAGE_MESSAGE
          parser.separator RSPEC_PATH_MESSAGE

          # can you run decko specs in card? doesn't seem right
          parser.on("-d", "--deck-spec [FILENAME(:LINE)]",
                    "Run spec for a Card deck file") do |file|
            add_tests file, :deck_items
          end
          parser.on("-c", "--core-spec [FILENAME(:LINE)]",
                    "Run spec for a Card core file") do |file|
            add_tests file, :core_items
          end
          parser.on("-m", "--mod [MODNAME]",
                    "Run all specs for a mod or matching a mod") do |mod|
            add_tests mod, :mod_items
          end
          parser.on("-s", "--[no-]simplecov", "Run with simplecov") do |s|
            options[:simplecov] = s ? "" : "COVERAGE=false"
          end
          parser.on("--rescue", "Run with pry-rescue") do
            process_rescue_opts opts
          end
          parser.on("--[no-]spring", "Run with spring") do |spring|
            process_spring_opts spring, opts
          end
          parser.on_tail("[LIST]") do |list|
            add_tests(list, :core_items)
          end
          parser.separator "\n"
        end

      private

        def add_tests item, kind=:core_items
          item ||= :all
          o = options[kind] ||= []
          if options[kind].include?(:all)
            warn 'multiple #{kind} with "all"'
          else
            o <<= item
          end
        end

        def process_rescue_opts opts
          if options[:executer] == "spring"
            puts "Disabled pry-rescue. Not compatible with spring."
          else
            options[:rescue] = "rescue "
          end
        end

        def process_spring_opts spring, opts
          if spring
            options[:executer] = "spring"
            if options[:rescue]
              options[:rescue] = ""
              puts "Disabled pry-rescue. Not compatible with spring."
            end
          else
            options[:executer] = "bundle exec"
          end
        end
      end
    end
  end
end
