# -*- encoding : utf-8 -*-

require "optparse"

module Decko
  class Commands
    class CucumberCommand
      # parses options to `decko cucumber` command
      class Parser < OptionParser
        # supports CucumberCommand::Parser class in parsing flags
        class Flagger
          def initialize parser, opts
            @parser = parser
            @opts = opts
          end

          def add_flags
            add_flag "DEBUG", "-d", "--debug", "Drop into debugger on failure"
            add_flag "FAST", "-f", "--fast", "Stop on first failure"
            add_flag "LAUNCH", "-l", "--launchy", "Open page on failure"
            add_flag "STEP", "-s", "--step", "Pause after each step"
          end

          def add_flag flag, *args
            @parser.on(*args) { |a| @opts[:env] << "#{flag}=1" if a }
          end
        end

        def parse_spring parser, opts
          parser.on("--[no-]spring", "Run with spring") do |spring|
            opts[:executer] = spring ? "spring" : "bundle exec"
          end
        end

        def initialize opts
          super() do |parser|
            parser.banner = "Usage: decko cucumber [DECKO ARGS] -- [CUCUMBER ARGS]\n\n"
            parser.separator "\nDECKO ARGS"
            opts[:env] = ["RAILS_ROOT=. RAILS_ENV=cucumber"]
            Flagger.new(parser, opts).add_flags
            parse_spring parser, opts
          end
        end
      end
    end
  end
end
