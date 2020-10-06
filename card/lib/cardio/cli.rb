require "rbconfig"
require "pathname"

module Cardio
  module ScriptLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at(
            "bindir", "ruby_install_name") ) + RbConfig::CONFIG["EXEEXT"]

    class <<self
      def script_file name
        File.join("script", name.to_s)
      end

      def exec_script! name
        cwd = Dir.pwd
        return unless in_application?(name) || in_application_subdirectory?(name)
        exec RUBY, script_file(name), *ARGV if in_application?(name)
        Dir.chdir("..") do
          # Recurse in a chdir block: if the search fails we want to be sure
          # the application is generated in the original working directory.
          exec_script!(name) unless cwd == Dir.pwd
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
    end
  end
end

# FIXME: get the command name (card/decko) from $0 ($COMMAND ?)
command = "card"
path = command == "card" ? "cardio" : command # alias card -> cardio paths
# If we are inside a Card application this method performs an exec and thus
# the rest of this script is not run.
Cardio::ScriptLoader.exec_script! command

require "rails/ruby_version_check"
Signal.trap("INT") { puts; exit(1) }

# if ARGV.first == 'plugin'
#  ARGV.shift
#  require "#{path}/commands/plugin_new"
# else

# end
# FIXME: if path/... not there, use "cardio" (skip aliasing above?)
require "#{path}/commands/application"
