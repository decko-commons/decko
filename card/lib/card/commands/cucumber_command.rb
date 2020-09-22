require File.expand_path("../command", __FILE__)

module Decko
  module Commands
    class CucumberCommand < Command
      def initialize args
        require "decko"
        require "./config/environment"
        @decko_args, @cucumber_args = split_args args
        @opts = {}
        @cucumber_args.append(Parser.new(@opts).parse!(@decko_args))
      end

      def command
        @cmd ||=
          "#{env_args} #{@opts[:executer] || "bundle exec"} cucumber #{require_args} #{feature_args}"
      end

      private

      def env_args
        env_args = @opts[:env].join " "
        # turn coverage off if not all cukes run
        env_args << " COVERAGE=false" if @cucumber_args.present?
        env_args << " RAILS_GROUPS=test,debug"
        env_args
      end

      def feature_args
        if @cucumber_args.empty?
          feature_paths.join(" ")
        else
          @cucumber_args.shelljoin
        end
      end

      def require_args
        "-r #{Decko.gem_root}/features " +
          feature_paths.map { |path| "-r #{path}" }.join(" ")
      end

      def feature_paths
        Card::Mod.dirs.map do |p|
          Dir.glob "#{p}/features"
        end.flatten
      end
    end
  end
end

require File.expand_path("../cucumber_command/parser", __FILE__)
