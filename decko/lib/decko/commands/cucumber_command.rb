# load the application so we can look in mods
require APP_PATH
require "cardio/command/command_base"
require "cardio/mod/dirs"

module Decko
  class Commands
    # handling of `decko cucumber` command
    class CucumberCommand < Cardio::Command::CommandBase
      require "decko/commands/cucumber_command/parser"

      def initialize args
        super()
        @decko_args, @cucumber_args = split_args args
        @opts = {}
        Parser.new(@opts).parse!(@decko_args)
      end

      def command
        @command ||=
          "#{env_args} #{@opts[:executer] || 'bundle exec'} " \
          "cucumber #{require_args} #{feature_args} #{@cucumber_args.shelljoin}"
      end

      private

      def env_args
        @opts[:env].join " "
      end

      # use implicit features unless feature made explicit (in FIRST arg!)
      def feature_args
        feature_paths.join(" ") unless @cucumber_args.first&.match?(/^\s*[^-]/)
      end

      def require_args
        "-r #{Decko.gem_root}/features " +
          feature_paths.map { |path| "-r #{path}" }.join(" ")
      end

      def feature_paths
        Cardio::Mod.dirs.map do |p|
          Dir.glob "#{p}/features"
        end.flatten
      end
    end
  end
end
