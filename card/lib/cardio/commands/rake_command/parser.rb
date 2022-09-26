# -*- encoding : utf-8 -*-

# require "optparse"
#
# module Cardio
#   class Commands
#     class RakeCommand
#       # parse decko/card -specific options for rake
#       class Parser < OptionParser
#         ONS = {
#           production: {
#             desc: "production database (default)"
#           },
#           test: {},
#           development: {},
#           all: {
#             desc: "production, test, and development database",
#             envs: %w[production development test]
#           }
#         }.freeze
#
#         def initialize command, opts
#           super() do |parser|
#             parser.banner =
#               "Usage:\n" +
#                 "  #{ScriptLoader.script_name} #{command} [options]".green +
#                 "\n\nRuns `rake #{ScriptLoader.script_name}:#{command}` task."
#             parser_ons parser, command do |env_array|
#               opts[:envs] = env_array
#             end
#           end
#         end
#
#         def parser_ons parser, command
#           ONS.each do |env, vals|
#             parser.on(*parser_on_opts(env, command, vals[:desc])) do
#               yield (vals[:envs] || [env.to_s])
#             end
#           end
#         end
#
#         def parser_on_opts env, command, desc
#           main = "--#{env}"
#           short = "-#{env.to_s[0]}"
#           desc ||= "#{env} database"
#           [main, short, "#{command} #{desc}"]
#         end
#       end
#     end
#   end
# end
