# -*- encoding : utf-8 -*-

require "optparse"
require "cardio/mod"
require "pry"

module Cardio
  class Command
    class RspecCommand
      # parse decko/card -specific options for RSpec
      class Parser < OptionParser
        RSPEC_PATH_MESSAGE = <<~MESSAGE.freeze

          #{Command.bin_name.upcase} ARGS

        MESSAGE

        RSPEC_BANNER = <<~BANNER.freeze

          Usage: #{Command.bin_name} rspec [#{Command.bin_name.upcase} ARGS] -- [RSPEC ARGS]

          RSPEC ARGS

          See https://rspec.info/features/3-12/rspec-core/command-line/ or 
          run card rspec -- -hb
        BANNER

        DESC = {
          m: "Run all specs for a mod or matching a mod"
        }.freeze

        def initialize opts
          super() do |parser|
            parser.banner = RSPEC_BANNER
            parser.separator RSPEC_PATH_MESSAGE

            # file_options parser, opts
            other_options parser, opts
            parser.separator "\n"
          end
        end

        private

        def file_options parser, opts
          parser.on("-m", "--mod MODNAME", DESC[:m]) do |file|
            opts[:files] = find_mod_file(file, Cardio.gem_root)
          end
        end

        def other_options parser, opts
          parser.on("-s", "--simplecov", "Run with simplecov") do |s|
            opts[:simplecov] = s
          end
          parser.on("--pry-rescue", "Run with pry-rescue") do
            process_rescue_opts opts
          end
          parser.on("--spring", "Run with spring") do |spring|
            process_spring_opts spring, opts
          end
        end

        def process_rescue_opts opts
          if opts[:executer] == "spring"
            puts "Disabled pry-rescue. Not compatible with spring."
          else
            opts[:rescue] = "rescue "
          end
        end

        def process_spring_opts spring, opts
          if spring
            opts[:executer] = "spring"
            if opts[:rescue]
              opts[:rescue] = ""
              puts "Disabled pry-rescue. Not compatible with spring."
            end
          else
            opts[:executer] = "bundle exec"
          end
        end

        def find_mod_file filename, base_dir
          # FIXME: - use Cardio::Mod lookup

          if File.exist?("mod/#{filename}") || File.exist?("#{base_dir}/mod/#{filename}")
            "#{base_dir}/mod/#{filename}"
          elsif (files = find_spec_file(filename, "mod"))&.present?
            files
          else
            find_spec_file(filename, "#{base_dir}/mod")
          end
        end

        def find_spec_file filename, base_dir
          file, line = filename.split(":")
          if file.include?("_spec.rb") && File.exist?(file)
            filename
          else
            find_matching_spec_files file, line, base_dir
          end
        end

        def find_matching_spec_files file, line, base_dir
          file = File.basename(file, ".rb").sub(/_spec$/, "")
          Dir.glob("#{base_dir}/**/#{file}_spec.rb").flatten.map do |spec_file|
            line ? "#{spec_file}:#{line}" : file
          end.join " "
        end
      end
    end
  end
end
