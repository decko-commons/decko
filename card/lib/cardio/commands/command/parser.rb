# -*- encoding : utf-8 -*-
require "optparse"

module Cardio
  module Commands
    class Command
      class Parser
        USAGE_MESSAGE = <<-EOT
            card new
        EOT

        def initialize
          @args = []
          @options = {}
        end
        # move to command/parser.rb
        attr_reader :options, :args

        def parse args
          # The options specified on the command line will be collected in
          # *options*.

          @options = self.class.new
          @args = OptionParser.new do |parser|
            @options.define_options parser  # load self.options (super too)
            parser.parse! args              # do the parse and set self.args
          end
          @options
        end

        def define_options parser
        end

      end
    end
  end
end
