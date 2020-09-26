# -*- encoding : utf-8 -*-
require "optparse"

module Card
  module Commands
    class RspecCommand
      class Parser < OptionParser
        #cmdname = 'card' # get from cmd
        #cmdnameup ="\U#{cmdname}"
        RSPEC_PATH_MESSAGE = <<-EOT

            {cmdnameup} ARGS

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
        def initialize opts
          super() do |parser|
            parser.banner = "Usage: #{cmdname} rspec [#{cmdnameup} ARGS] -- [RSPEC ARGS]\n\n" \
                            "RSPEC ARGS"
            parser.separator RSPEC_USAGE_MESSAGE
            parser.separator RSPEC_PATH_MESSAGE

            # can you run decko specs in card? doesn't seem right
            parser.on("-d", "--deck-spec FILENAME(:LINE)",
                      "Run spec for a Card deck file") do |file|
              opts[:deck_files] = file
            end
            parser.on("-c", "--core-spec FILENAME(:LINE)",
                      "Run spec for a Card core file") do |file|
              opts[:core_files] = file
            end
            parser.on("-m", "--mod MODNAME",
                      "Run all specs for a mod or matching a mod") do |mod|
              opts[:mods] = mod
            end
            parser.on("-s", "--[no-]simplecov", "Run with simplecov") do |s|
              opts[:simplecov] = s ? "" : "COVERAGE=false"
            end
            parser.on("--rescue", "Run with pry-rescue") do
              process_rescue_opts opts
            end
            parser.on("--[no-]spring", "Run with spring") do |spring|
              process_spring_opts spring, opts
            end
            parser.separator "\n"
          end
        end

        private

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

        # move: to command processing
        def find_mod_file filename, base_dir
          if File.exist?("mod/#{filename}") || File.exist?("#{base_dir}/mod/#{filename}")
            "#{base_dir}/mod/#{filename}"
          elsif (files = find_spec_file(filename, "mod"))&.present?
            files
          else
            find_spec_file(file, "#{base_dir}/mod")
          end
        end

        def find_spec_file filename, base_dir
          file, line = filename.split(":")
          if file.include?("_spec.rb") && File.exist?(file)
            filename
          else
            file = File.basename(file, ".rb").sub(/_spec$/, "")
            Dir.glob("#{base_dir}/**/#{file}_spec.rb").flatten.map do |spec_file|
              line ? "#{spec_file}:#{line}" : file
            end.join(" ")
          end
        end
      end
    end
  end
end
