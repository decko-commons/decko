# -*- encoding : utf-8 -*-
require "optparse"

module Cardio
  module Commands
    class RakeCommand
      class Parser < OptionParser
        def initialize command, opts
          super() do |parser|
            parser.banner = "Usage: card #{command} [options]\n\n" \
                          "Run card:#{command} task on the production "\
                          " database specified in config/database.yml\n\n"
            parser.on("--production", "-p",
                      "#{command} production database (default)") do
              opts[:envs] = ["production"]
            end
            parser.on("--test", "-t",
                      "#{command} test database") do
              opts[:envs] = ["test"]
            end
            parser.on("--development", "-d",
                      "#{command} development database") do
              opts[:envs] = ["development"]
            end
            parser.on("--all", "-a",
                      "#{command} production, test, and development database") do
              opts[:envs] = %w(production development test)
            end
          end
        end
      end
    end
  end
end
