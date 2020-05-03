# -*- encoding : utf-8 -*-
require "optparse"

module Decko
  module Commands
    class RspecCommand
      class Parser < OptionParser
        RSPEC_PATH_MESSAGE = <<-EOT

            DECKO ARGS

            You don't have to give a full path for FILENAME; the basename is enough.
            If FILENAME does not include '_spec', then rspec searches for the
            corresponding spec file.
            The line number always refers to the example in the spec file.

        EOT

        def initialize opts
          super() do |parser|
            parser.banner = "Usage: decko rspec [DECKO ARGS] -- [RSPEC ARGS]\n\n" \
                            "RSPEC ARGS"
            parser.separator RSPEC_PATH_MESSAGE

            parser.on("-d", "--spec FILENAME(:LINE)",
                      "Run spec for a Decko deck file") do |file|
              opts[:files] = find_spec_file(file, "#{Decko.root}/mod")
            end
            parser.on("-c", "--core-spec FILENAME(:LINE)",
                      "Run spec for a Decko core file") do |file|
              opts[:files] = find_spec_file(file, Cardio.gem_root)
            end
            parser.on("-m", "--mod MODNAME",
                      "Run all specs for a mod or matching a mod") do |file|
              opts[:files] = find_mod_file(file, Cardio.gem_root)
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
