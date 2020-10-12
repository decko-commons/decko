require "rbconfig"
require "pathname"

module Cardio
  module ScriptLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at(
            "bindir", "ruby_install_name") ) + RbConfig::CONFIG["EXEEXT"]

    PATH_ALIAS = { 'cardio' => 'card', 'decko' => 'deck' }

    class <<self
      def script_file name
        File.join("script", name.to_s)
      end

      attr_reader :command

      def base
        @base ||= begin
          @command = ((cmd = $0) =~ /(script)?\/([^\/]+)$/) ? $2 : cmd
          @notscript = $1.nil?

          @command = PATH_ALIAS[@command] unless PATH_ALIAS[@command].nil?
          case @command
            when 'deck'; 'decko'
            #when 'card'; 
            else         'cardio'
            end
        end
      end

      # If we are NOT inside a Card application this method performs calls
      # the block when given on the parsed scriptname.
      # Parses command to run and require base from the command and aliases
      def exec_script! &block
        base # make sure base/command get set from $0
        cwd = Dir.pwd
        unless @notscript && ( in_application?(@command) ||
               in_application_subdirectory?(@command) )
          return (yield(@base) if block_given?)
        end
        exec RUBY, script_file(@command), *ARGV if in_application?(@command)
        Dir.chdir("..") do
          # Recurse in a chdir block: if the search fails we want to be sure
          # the application is generated in the original working directory.
          exec_script!(@command) unless cwd == Dir.pwd
        end
      rescue SystemCallError
        # could not chdir, no problem just return
      end

      def in_application? name
        File.exist?(script_file name)
      end

      def in_application_subdirectory? name, path=Pathname.new(Dir.pwd)
        File.exist?(File.join(path, script_file(name))) ||
          !path.root? && in_application_subdirectory?(name, path.parent)
      end

      def command_path
        "#{base}/commands/#{@command}_command"
      end
    end
  end
end

 Cardio::ScriptLoader.exec_script! do |base|

  require "rails/ruby_version_check"
  Signal.trap("INT") { puts; exit(1) }

  # if base == 'plugin'
  #  ARGV.shift
  #  require "#{base}/commands/plugin_new"
  # else

  # end
  # FIXME: if path/... not there, use "cardio" (skip aliasing above?)
  require "#{base}/commands/application"
end
