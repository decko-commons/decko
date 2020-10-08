require File.expand_path("../command", __FILE__)

module Cardio
  module Commands
    class RspecCommand < Command
      def initialize args
        require "rspec/core"

        @opts = RspecCommand::Parser.new.parse(ARGV).options
        @rspec_args, @cmd_args =
          if ARGV.include?('--')
            split_args(ARGV)
          else
            [[], ARGV]
          end
      end

      def command
c=
        "#{env_args} #{@opts[:executer]} #{@opts[:rescue]}" \
          "rspec #{@rspec_args.shelljoin} #{spec_files_from_opts(@opts)*' '} "\
          "--exclude-pattern \"./card/vendor/**/*\""
      end

      private

      def env_args
        ["RAILS_ROOT=.", coverage].compact.join " "
      end

      def has_specs?
        @opts[:mod_items]&.any? ||
          @opts[:deck_items]&.any? ||
          @opts[:card_items]&.any?
      end

      def coverage
        # no coverage if rspec was started with file argument
        if (has_specs? || @rspec_args.any?) && !@opts[:simplecov]
          @opts[:simplecov] = "COVERAGE=false"
        end
        @opts[:simplecov]
      end

      def spec_files_from_opts opts
        find_mod_specs(opts[:mod_items]) +
        find_deck_specs(opts[:deck_items]) +
        find_core_specs(opts[:core_items])
      end
      def find_mods mods, base_dir
        #def find_mod_file filename, base_dir
        mods.map do |modname|
          if File.exist?("mod/#{modname}") || File.exist?("#{base_dir}/mod/#{modname}")
            "#{base_dir}/mod/#{filename}"
          elsif (files = find_tests(filename, "mod"))&.present?
            files
          else
            find_spec_file(file, "#{base_dir}/mod")
          end
        end
      end
 
      def find_tests names, base_dir
        #def find_spec_file filename, base_dir
        names.map do |filename|
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

      def find_mod_specs mods
        []
      end

      def find_deck_specs files
        #find_tests files, basedir
        []
      end

      def find_core_specs files
        []
      end
    end
  end
end

require File.expand_path("../rspec_command/parser", __FILE__)
